locals {
  # One managed pool per OS: independent sku, concurrency and image list.
  # Aliases mirror the form Azure normalizes to, so plans stay clean.
  pools = {
    linux = {
      sku                = "Standard_D2ds_v5"
      maximumConcurrency = 2
      parallelism        = 2
      subnet_index       = 0 # 10.0.0.0/24
      subnet_name        = "snet01"
      images = [
        {
          ephemeralType      = "Automatic"
          wellKnownImageName = "ubuntu-24.04"
          buffer             = "*"
          aliases = [
            "ubuntu-24.04",
            "ubuntu-24.04/latest"
          ]
        }
      ]
    }
    windows = {
      # AMD family (standardDADSv5) — draws from a separate MDP core quota
      # than the linux pool's standardDDSv5, so both fit the 5-core default
      sku                = "Standard_D2ads_v5"
      maximumConcurrency = 2
      parallelism        = 2
      subnet_index       = 2 # 10.0.2.0/24 — index 1 is the pe subnet
      subnet_name        = "snet02"
      images = [
        {
          ephemeralType      = "Automatic"
          wellKnownImageName = "windows-2025"
          buffer             = "*"
          aliases = [
            "windows-2025",
            "windows-2025/latest"
          ]
        }
      ]
    }
  }
}
