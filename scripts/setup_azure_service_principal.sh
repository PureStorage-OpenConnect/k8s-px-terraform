#!/bin/bash

set -e +u
set -o pipefail
set -x


#########################
# The command line help #
#########################
display_help() {
  echo "$(date) --> Usage: $0 [option...] ./setup_azure_service_principal.sh <tenantID> <subscriptionID>"
  echo
  exit 1
}

# tenant_id can found by logging to azure by running `az login`
TENANT_ID=$1

# subscription can be found by running `az account list -o table`
SUBSCRIPTION_ID=$2

echo
if [[ -z $TENANT_ID || -z $SUBSCRIPTION_ID ]]; then
  echo -e "Insufficient parameters passed. \n"
  display_help;
fi

echo -e "$(date) - tenant_id       :   ${TENANT_ID}"
echo -e "$(date) - subscription_id :   ${SUBSCRIPTION_ID}"
echo



# Set the subscription to run az commands against
az account set --subscription "$SUBSCRIPTION_ID"

## Create service principal

#SERVICE_PRINCIPAL_JSON=$(az ad sp create-for-rbac --skip-assignment --name px-ops-service-principal -o json)
az ad sp create-for-rbac --skip-assignment --name px-ops-service-principal -o json > ./keys/azure-px-ops-service-principal.json

#gcloud iam service-accounts keys create "$FOLDER"/"$PROJECT"-cluster-ops.json --iam-account $CLOUDOPS@$PROJECT.iam.gserviceaccount.com

SERVICE_PRINCIPAL=$(cat ./keys/azure-px-ops-service-principal.json| jq -r '.appId')
#SERVICE_PRINCIPAL_SECRET=$echo $SERVICE_PRINCIPAL_JSON | jq -r '.password')


az role assignment create --assignee "$SERVICE_PRINCIPAL" \
  --scope "/subscriptions/$SUBSCRIPTION_ID" \
  --role Contributor

