#!/usr/bin/env bash
set -e -u
set -o pipefail
. vars

LOG_FILE="$(pwd)/debug.log"
##Help text
  howtouse() {
      echo -e "\nUsage:\n  $0 [node-name]\nExample:\n $0 node01\n"
      exit 1
  }

  printf "\n\n$(date -u)\n-------------------------------------------\n" >> "${LOG_FILE}"
##Test if command-line parameters exist.
  printf "Testing if command-line parameters exist: " >> "${LOG_FILE}"
  if [[ -z "${1+x}" ]]; then
    printf "\n"
    echo -e "\nPlease pass node name you want to remove as a command-line parameter." | tee -a "${LOG_FILE}"
    howtouse
  fi
  printf "Successful!\n" >> "${LOG_FILE}"
  HOST_TO_REMOVE="${1}"

##Checking if inventory file exists.
  printf "Checking if inventory file exists: " >> "${LOG_FILE}"
  if [ ! -f "kubespray/${CONFIG_FILE}" ]; then
    printf "\nFile not found: ./kubespray/${CONFIG_FILE} \n\nMake sure you are running the script from the folder where you initially ran the terraform commands for setting up the cluster.\n\n"
    exit 1
  fi
  printf "Successful!\n" >> "${LOG_FILE}"

  cd kubespray;
  printf "\nGathering information about the node, it may take some time...\n\n"
  printf "Lookup if node is existing in the inventory: " >> "${LOG_FILE}"
  FIND_HOST="$(ansible -i "${CONFIG_FILE}" --list-hosts ${HOST_TO_REMOVE} 2> /dev/null | tail -1 | xargs )"
  if [[ "${FIND_HOST}" != "${HOST_TO_REMOVE}" ]]; then
    printf "\n"
    printf "Node '${HOST_TO_REMOVE}' does not exist in the inventory 'kubespray/${CONFIG_FILE}'.\n\n" | tee -a "${LOG_FILE}"
    exit 1
  fi
  printf "Successful!\n" >> "${LOG_FILE}"

  printf "Checking if host is a member of the k8s cluster: " >> "${LOG_FILE}"
  ${kbCtl} --kubeconfig="${vKubeConfig}" get nodes ${HOST_TO_REMOVE} 2>> "${LOG_FILE}" >/dev/null &&
      printf "Successful!\n" >> "${LOG_FILE}" || \
      { printf "\n\n"; printf "Node '${HOST_TO_REMOVE}' is not a member of the cluster.\n\n" | tee  -a "${LOG_FILE}"; exit 1; }

  printf "Fetch IP of the node from the inventory: " >> "${LOG_FILE}"
  HOST_IP="$(ansible -i "${CONFIG_FILE}" -m debug -a "var=hostvars[inventory_hostname].ip" ${HOST_TO_REMOVE} 2> /dev/null | \
    grep -i 'hostvars\[inventory_hostname\].ip":' | cut -f2 -d":" | xargs)"
  printf "IP is: $HOST_IP\n" >> "${LOG_FILE}"

  printf "Checking if node is accessible and passwordless ssh is working: " >> "${LOG_FILE}"
  timeout 25 ssh -oBatchMode=yes ${PX_ANSIBLE_USER}@${HOST_IP} "true" || { printf "\nSSH Connection failed: ${PX_ANSIBLE_USER}@${HOST_IP}\n\nMake sure the host is reachable and password-less ssh is set up correctly.\n\n"; exit 1; }
  printf "Successful!\n" >> "${LOG_FILE}"

  printf "Checking if ssh user has root permissions: " >> "${LOG_FILE}"
#  timeout 25 ssh -oBatchMode=yes ${PX_ANSIBLE_USER}@${HOST_IP} "sudo hostname" || { printf "\nSSH Connection failed: ${PX_ANSIBLE_USER}@${HOST_IP}\n\nMake sure the host is reachable and password-less ssh is set up correctly.\n\n"; exit 1; } 
  timeout 25 ssh -oBatchMode=yes ${PX_ANSIBLE_USER}@${HOST_IP} "sudo hostname" >/dev/null 2>&1 || { printf "\nSSH user '${PX_ANSIBLE_USER}' does have root or sudo permissions, or it is not allowed to run the commands without entering the password.\n\n"; exit 1;}
  printf "Successful!\n" >> "${LOG_FILE}"

  printf "Find a portworx pod: " >> "${LOG_FILE}"
  PX_POD="$(${kbCtl} --kubeconfig="${vKubeConfig}" get pods --no-headers -l name=portworx -n portworx -o wide | grep -v ${HOST_TO_REMOVE} | xargs | cut -f1 -d' ')"
  printf "${PX_POD}\n" >> "${LOG_FILE}"

  CONFIRMATION=n
  printf "Asking form the user: Do you want to remove '${HOST_TO_REMOVE}' from the cluster [y/n]: " >> "${LOG_FILE}"
  while true; do
    read -p "Do you want to remove '${HOST_TO_REMOVE}' from the cluster [y/n]: " CONFIRMATION
    if [[ "${CONFIRMATION,,}" == "y" ]]; then
      printf "${CONFIRMATION}\n" >> "${LOG_FILE}"
      break
    elif [[ "${CONFIRMATION,,}" == "n" ]]; then
      printf "Operation canceled by the user!\n\n" | tee -a "${LOG_FILE}"; exit 0;
    fi
  done
  
  printf "Checking if node is a member of the Portworx cluster: " >> "${LOG_FILE}"
  PX_NODE="$(${kbCtl} --kubeconfig="${vKubeConfig}" exec -n portworx $PX_POD -c portworx -- /opt/pwx/bin/pxctl cluster list 2>/dev/null | grep -A100 "Nodes in the cluster:"| grep "${HOST_TO_REMOVE}" |xargs | cut -f2 -d' ' || true)"
  if [[ "${PX_NODE}" != "" ]]; then
    printf -- "Yes!\n" >> "${LOG_FILE}"
    printf "\n"
    printf "Preparing node for removal...\n" | tee -a "${LOG_FILE}"

    printf "Putting portworx node in maintenance mode: " >> "${LOG_FILE}"
    timeout 25 ssh -oBatchMode=yes ${PX_ANSIBLE_USER}@${HOST_IP} "
        pxctl service maintenance --enter -y
        " >>"${LOG_FILE}" 2>&1 || true
    sleep 10
    printf -- "Done!\n" >> "${LOG_FILE}"

    printf "Setting host as 'cordoned': " >> "${LOG_FILE}"
    ${kbCtl} --kubeconfig="${vKubeConfig}" cordon ${HOST_TO_REMOVE} > /dev/null 2>&1
    ${kbCtl} --kubeconfig="${vKubeConfig}" get nodes ${HOST_TO_REMOVE} -o jsonpath='{.spec.unschedulable}{"\n"}' >> "${LOG_FILE}" 2> /dev/null|| printf "Unable to set cordon, Ignoring.\n"  >> "${LOG_FILE}"

    printf "Setting label on the node to remove portworx from the host.\n" >> "${LOG_FILE}"
    ${kbCtl} --kubeconfig="${vKubeConfig}" label nodes ${HOST_TO_REMOVE} px/enabled=false --overwrite  > /dev/null 2>&1
    
    printf "Getting portworx node UID: " >> "${LOG_FILE}"
    NODE_UID="$(${kbCtl} --kubeconfig="${vKubeConfig}" get storagenodes.core.libopenstorage.org ${HOST_TO_REMOVE} -n portworx -o jsonpath={.status.nodeUid} 2>/dev/null)" || true
    printf "${NODE_UID}\n" >> "${LOG_FILE}"
    sleep 10

    printf "Cleaning portworx node before removal: " >> "${LOG_FILE}"
    timeout 100 ssh -oBatchMode=yes ${PX_ANSIBLE_USER}@${HOST_IP} "
        sudo systemctl stop portworx
        sudo systemctl disable portworx
        sudo rm -f /etc/systemd/system/portworx*
        grep -q '/opt/pwx/oci /opt/pwx/oci' /proc/self/mountinfo && sudo umount /opt/pwx/oci
        pxctl service node-wipe --all
        " >/dev/null 2>&1 || true
    printf -- "Finished!\n" >> "${LOG_FILE}"

    printf "Removing node from the portworx storage cluster if available: " >> "${LOG_FILE}"
    ${kbCtl} --kubeconfig="${vKubeConfig}" exec -n portworx $PX_POD -c portworx -- /opt/pwx/bin/pxctl cluster delete ${NODE_UID} >>"${LOG_FILE}" 2>&1 || true
    printf -- "Done!\n" >> "${LOG_FILE}"
  else
    printf -- "No!\n" >> "${LOG_FILE}"
  fi
##Starting kubespray remove node process.
  printf "Starting kubespray node removal process..." >> "${LOG_FILE}"
  #Gathering facts
    ansible -i "${CONFIG_FILE}" -m  setup all > /dev/null
  #Removing
    ansible-playbook -i "${CONFIG_FILE}" remove-node.yml -u"${PX_ANSIBLE_USER}" -b -e "node=${HOST_TO_REMOVE}" -e "skip_confirmation=yes"

cd ..
sleep 5
${kbCtl} --kubeconfig="${vKubeConfig}" get nodes

