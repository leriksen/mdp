# Managed DevOps Pools (mdp)

This Terraform codebase creates the Azure and Azure DevOps resources required to link an
Azure Dev Center Project Managed DevOps Pool (MDP) to an Azure DevOps organisation. It:

- Creates the Dev Center, Dev Center Project, VNet/subnet, and the Managed DevOps Pool itself.
- Links the pool to **every** project in the Azure DevOps organisation (not just one).
- Authorizes **every pipeline** in every project to use the pool's queue.

See [terraform/README.md](terraform/README.md) for how to bootstrap a new TFC-connected
workspace from this codebase.

## Design considerations

### Networking / subnet sizing

- Each Dev Center MDP pool that's injected into your own VNet requires its own **dedicated,
  delegated subnet** (`Microsoft.DevOpsInfrastructure/pools` delegation) — a subnet can't be
  shared across pools. This means subnet sizing and address space planning has to happen
  **upfront**, before you know exactly how large the pool will need to scale. Undersizing means
  a resize/migration later; oversizing wastes address space.
- Standard VNet controls still apply on top of that subnet: NSGs can restrict inbound/outbound
  traffic, and route tables / UDRs / a firewall/NVA can force traffic through inspection points,
  same as any other subnet. (An NSG with no custom rules is not a restriction — Azure's default
  rules already allow outbound Internet, so nothing extra is required unless you want to
  actively lock it down or force egress through a specific path.)
- Agents are provisioned in the **Azure region the pool is configured for** — there's no
  cross-region bursting. Pick the region closest to the dependencies (repos, package feeds,
  container registries, etc.) the pipelines need to reach.

### VM sizing, images, and quota

- VM size (`sku`) is set **per pool**, not per organisation — different pools can use different
  SKUs to match their workload (e.g. a small SKU for lint/build pools, a larger one for
  data/ML workloads).
- **Watch Azure CPU quota carefully.** Quota is enforced per VM *family*, per region, per
  subscription — not overall vCPU quota. It's entirely possible to have 40 vCPUs of headroom
  at the subscription level while a specific family (e.g. `standardDADSv5Family`) sits at a
  0-core limit. Check `az vm list-usage -l <region>` for the specific family your chosen SKU
  belongs to before committing to it, and remember that ephemeral-OS-disk support and Gen2
  support also vary by SKU — not every SKU in a family with quota will actually be usable.
- A single pool **can** be configured with multiple images and rely on pipeline `demands` to pick
  between them at queue time, but in practice it's usually cleaner to **run separate pools per
  image family** (e.g. one Ubuntu pool, one Windows pool) rather than one mixed pool. This keeps
  scaling, quota, and buffer/standby sizing decisions independent per OS family instead of
  entangled in one pool's scale logic.
- Beyond the built-in "well-known" images, you can select more specific images from the Azure
  Compute Gallery / Marketplace — e.g. RHEL, CentOS, or vendor-tuned software images — for
  workloads that need a specific OS/tooling baseline.
- There's also the option to build fully custom images (e.g. via Packer pipelines) baked with
  AEMO-specific tooling, agents, and dependencies pre-installed, and publish them to a shared
  Compute Gallery for pools to consume.
- **Spot VM instances are not supported** by Managed DevOps Pools today. The underlying VMSS is
  provisioned in a Microsoft-managed subscription, and the exposed `fabricProfile` schema has no
  priority/eviction-policy field — there's currently no way to get Spot pricing through MDP. If
  Spot pricing is a hard requirement, the fallback is self-managed Azure DevOps VMSS agent
  pools (the older, unmanaged pattern), at the cost of losing MDP's managed image lifecycle and
  scaling.

### Startup / provisioning features

- Certificate and proxy configuration can be injected into the agent at startup (e.g. pulling
  observed certificates during provisioning, or configuring the agent to run behind a proxy).
- Azure Key Vault integration is available — a pool's managed identity can be granted access to
  fetch secrets/certificates from a Key Vault during provisioning, so they're present on the
  machine before pipelines start running on it.
- Data disks can be attached to pool VMs, including disks pre-populated with application data,
  so you don't need a larger OS disk/image just to carry extra data.

### Billing and parallelism

- Billing is based on **compute + storage + egress** for the pool's VMs, in addition to whatever
  **self-hosted parallelism** licensing you carry in Azure DevOps for the organisation.
- Total Azure DevOps organisation **parallelism** and each individual pool's **agent scale
  limits** (`maximumConcurrency` / buffer / standby size) need to be kept aligned — if pool scale
  limits exceed the parallelism you've licensed, jobs will queue waiting for a parallel job slot
  even though agents are available (and vice versa, licensed parallelism is wasted if pools
  can't scale to use it).

## Roadmap (coming features, not yet available)

- Mixing VM sizes within a single pool.
- Spot instance support.
