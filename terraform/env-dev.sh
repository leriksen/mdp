#export TF_WORKSPACE="monitor"
export ARM_TENANT_ID="$(cat .tenant_id)"
export ARM_SUBSCRIPTION_ID="$(cat .subscription_id)"
export ARM_CLIENT_ID="$(cat .client_id)"
export ARM_CLIENT_SECRET="$(cat .client_secret)"

export TF_VAR_env="dev"

