#!/usr/bin/env bash
set -e -u
set -o pipefail
. vars


##Help text
  howtouse() {
      echo -e "\nUsage:\n  $0 [node-name]\nExample:\n  $0 node01\n"
      exit 1
  }

##Test if command-line parameters exist.
  if [[ -z "${1+x}" ]]; then
    echo -e "\n\nError: Node name not detected, Please pass it as the command-line parameters."
    howtouse
  fi
  HOST_TO_REMOVE="${1}"

#Checking if inventory file exists.
  if [ ! -f "kubespray/${CONFIG_FILE}" ]; then
    printf "\nFile not found: ./kubespray/${CONFIG_FILE} \n\nMake sure you are running the script from the folder where you initially ran the terraform commands for setting up the cluster.\n\n"
    exit 1
  fi


##Removing node.
  cd kubespray;

  #Lookup if node is existing in the inventory
  FIND_HOST="$(ansible -i "${CONFIG_FILE}" --list-hosts ${HOST_TO_REMOVE} 2> /dev/null | tail -1 | xargs )"

  if [[ "${FIND_HOST}" == "${HOST_TO_REMOVE}" ]]; then
    ansible-playbook -i "${CONFIG_FILE}" remove-node.yml -u"${PX_ANSIBLE_USER}" -b -e "node=${HOST_TO_REMOVE}"
  else
    echo -e "\nCould not find the host '${HOST_TO_REMOVE}' in the inventory '${CONFIG_FILE}' file. So, it can not be removed.\n"
    exit 1
  fi

  cd ..
  sleep 5
  ${kbCtl} --kubeconfig="${vKubeConfig}" get nodes
