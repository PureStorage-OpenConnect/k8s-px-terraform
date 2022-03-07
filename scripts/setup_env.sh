#!/bin/bash
set -e +u
set -o pipefail
#set -x #enable only when debug is needed

#########################
# The command line help #
#########################
display_help() {
  echo "$(date) --> Usage: $0 [option...] {aws|gcloud|azure|vm|baremetal} {UniqueIdForTheCluster} {RegionOrDataCenter}" >&2
  echo "$(date) -->  AWS        for example: ./setup_env.sh aws <accout-placeholder> us-west-2"
  echo "$(date) -->             for example: ./setup_env.sh aws 1234567 global [Note: requires Admin privileges to create Group, policy etc]"
  echo "$(date) -->  GCloud     for example: ./setup_env.sh gcloud dev us-east4"
  echo "$(date) -->  Azure      for example: ./setup_env.sh azure dev us-east4"
  echo "$(date) -->  VM         for example: ./setup_env.sh vm cluster01 ps-lab-01"
  echo "$(date) -->  BareMetal  for example: ./setup_env.sh baremetal cluster01 ps-lab-01"
  echo
  exit 1
}

CLOUD_ENV=$1
CLOUD_ACCT=$2
CLOUD_REGION=$3
TF_DIR="../terraform-live/${CLOUD_ENV}/${CLOUD_ACCT}/${CLOUD_REGION}"
TEMPLATE_DIR="../templates/${CLOUD_ENV}"

echo
if [[ -z $CLOUD_ENV || -z $CLOUD_ACCT || -z $CLOUD_REGION ]]; then
  echo -e "Insufficient parameters passed. \n"
  display_help;
fi

echo -e "$(date) - Environment chosen is:    ${CLOUD_ENV}"
echo -e "$(date) - Cluster Identifier:       ${CLOUD_ACCT}"
echo -e "$(date) - Region/Data Center:       ${CLOUD_REGION}"
echo

if [[ ! -d ${TEMPLATE_DIR} ]]; then
  echo
  echo  -e "\nError: No template exists for the \"${CLOUD_ENV}\" environment at ${TEMPLATE_DIR}\n"
  echo
  display_help;
  exit 1
fi

#Create the directory to host the terraform for the project.
mkdir -p "${TF_DIR}"

#Copy the resources from the template folder
if [[ $CLOUD_ENV == "aws" ]] && [[ $CLOUD_REGION == "global" ]]; then
   cp -r ${TEMPLATE_DIR}/global/* "${TF_DIR}/"
else
   cp -r ${TEMPLATE_DIR}/*  "${TF_DIR}/"
fi

echo "$(date) - Copied Files from the template folder to target location ${TF_DIR} -- completed"


if [[ $CLOUD_ENV == "aws" ]]; then
  aws s3 ls  > /dev/null 2>&1 || { echo "AWS cli not able to connect, make sure it is configured properly." && exit; };
  [ -e "${TF_DIR}/terraform.tfvars" ] && sed -ie "s/aws_region_id/${CLOUD_REGION}/g" "${TF_DIR}/terraform.tfvars"
  export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
  export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
  if [[ "$(aws configure get aws_session_token)X" != "X"  ]]; then
    export AWS_SESSION_TOKEN=$(aws configure get aws_session_token)
  fi
elif [[ $CLOUD_ENV == "gcloud" ]]; then
  #Validate here
  sed -ie "s/google_region_replaceme/${CLOUD_REGION}/g" "${TF_DIR}/terraform.tfvars"
  
elif [[ $CLOUD_ENV == "azure" ]]; then
  SSH_PublicKey=$(cat ~/.ssh/id_rsa.pub)
  SERVICE_PRINCIPAL_JSON=$(az ad sp create-for-rbac --skip-assignment --name ps-aks-service-account -o json)
  SERVICE_PRINCIPAL_APPID=$(echo "$SERVICE_PRINCIPAL_JSON" | jq -r '.appId')
  SERVICE_PRINCIPAL_SECRET=$(echo "$SERVICE_PRINCIPAL_JSON" | jq -r '.password')
  SERVICE_PRINCIPAL_TENANT=$(echo "$SERVICE_PRINCIPAL_JSON" | jq -r '.tenant')
  
  sed -ie "s/AZURE_LOCATION_ID/${CLOUD_REGION}/g" "${TF_DIR}/terraform.tfvars"
  sed -ie "s/SvcPID/${SERVICE_PRINCIPAL_APPID}/g" "${TF_DIR}/terraform.tfvars"
  sed -ie "s/SvcPKEY/${SERVICE_PRINCIPAL_SECRET}/g" "${TF_DIR}/terraform.tfvars"
  sed -ie "s/SvcAPPID/${SERVICE_PRINCIPAL_APPID}/g" "${TF_DIR}/terraform.tfvars"
  sed -ie "s/SvcTID/${SERVICE_PRINCIPAL_TENANT}/g" "${TF_DIR}/terraform.tfvars"
  #sed -ie "s/SSHKEY/${SSH_PublicKey}/g" "${TF_DIR}/terraform.tfvars"
  echo "Completed populating TFVARS for Azure"
elif [[ $CLOUD_ENV == "vm" || $CLOUD_ENV == "baremetal" ]]; then
  ##Check utilities
  for util in grep sed git pip3 python3; do
    if ! which $util >& /dev/null; then
      echo "ERROR: $util binary not found. Aborting."
      exit 1
    fi
  done

  if [[ -z $vHOSTS ]]; then 
    echo -e "Error: the vHOSTS environment variable not set. Please set it by assigning all host IPs separated by white space";
    echo -e "\nExample:"
    echo -e "export vHOSTS=\"192.168.10.51 192.168.10.52 192.168.10.53 192.168.10.54 192.168.10.55\"\n\n";
    exit 1;
  fi
  if [[ -z $vSSH_USER ]]; then
    echo -e "Error: the vSSH_USER environment variable not set. Please set with the ssh user name";
    echo -e "\nExample:"
    echo -e "export vSSH_USER=\"root\"\n\n";
    exit 1;
  fi
  
  #Create the directory to host the terraform for the region
  printf "Checking connectivity using SSH..."
  vRETURN=$(for i in $vHOSTS ;do ssh ${vSSH_USER}@${i} 'printf $(hostname -f)';printf ",${i} " ; done | xargs)
  cat "${TF_DIR}/cluster-config-vars.template" | \
  sed "s/XX_HOST_IPS_XX/${vRETURN}/g" | \
  sed "s,XX_SSH_USER_XX,${vSSH_USER},g" | \
  sed "s,XX_CLUSTER_NAME_XX,${CLOUD_ACCT},g" > ${TF_DIR}/cluster-config-vars
  rm ${TF_DIR}/cluster-config-vars.template
  chmod -R ug+x ${TF_DIR}
  printf "Successful\n\n"
else 
  echo "Unknown option selected for the environment, Choose one of the: aws|gcloud|azure|vm|baremetal." 
  display_help;
  exit; 
fi

echo "Changing directory to target directory - ${TF_DIR}"
cd "${TF_DIR}"

[ -e terraform.tfvarse ] && rm terraform.tfvarse

#export PS1=$(pwd):$PS1

echo "Opening a new shell with the Target directory"
$SHELL;

