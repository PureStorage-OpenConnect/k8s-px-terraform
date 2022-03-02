#!/usr/bin/env bash
set -e -u
set -o pipefail
. vars


##Help text
  howtouse() {
      echo -e "\nUsage:\n  $0 [IP-1] [IP-2] [IP-3] [IP-N]\nExample:\n  $0 192.168.1.55 192.168.1.56 192.168.1.57\n"
      exit 1
  }

##Test if command-line parameters exist.
  if [[ -z "${1+x}" ]]; then
    echo -e "\n\nError: No IP detected, Please pass one or more IPs as the command-line parameters."
    howtouse
  fi

#Checking if inventory file exists.
  if [ ! -f "kubespray/${CONFIG_FILE}" ]; then
    printf "\nFile not found: ./kubespray/${CONFIG_FILE} \n\nRequired file not found. Make sure you are running the script for an already set up cluster.\n\n"
    exit 1
  fi

cd kubespray;

##Checking if hosts are accessible.
  HOST_IPS="$@";
  for i in $HOST_IPS; do
    timeout 5 ssh ${PX_ANSIBLE_USER}@${i} "true" || { printf "\nSSH Connection failed: ${PX_ANSIBLE_USER}@${i}\n\nMake sure the ssh user and the ip is correct and password-less ssh is set up correctly.\n\n"; exit 1; } 
  done


vRETURN=$(for i in $HOST_IPS ;do ssh ${PX_ANSIBLE_USER}@${i} 'printf $(hostname -f)';printf ",${i} " ; done | xargs)
declare -a IPS=(${vRETURN})

##Starting main process.
  python3 "contrib/inventory_builder/inventory.py" add ${IPS[@]}
  ansible all -i "${CONFIG_FILE}" -m ping -u"${PX_ANSIBLE_USER}" -b
  ansible-playbook -i "${CONFIG_FILE}" "facts.yml" -u"${PX_ANSIBLE_USER}" -b 
  
  if [[ "${PX_METALLB_ENABLED}" == "true" ]]; then
    vMETALLB_VARS="{\"metallb_ip_range\": [\"${PX_METALLB_IP_RANGE}\"]}"
    ansible-playbook -i "${CONFIG_FILE}" "scale.yml" -u"${PX_ANSIBLE_USER}" -b --extra-vars "kubeconfig_localhost=true kubectl_localhost=true kube_proxy_strict_arp=true metallb_enabled=true" --extra-vars "${vMETALLB_VARS}"
  else
    ansible-playbook -i "${CONFIG_FILE}" "scale.yml" -u"${PX_ANSIBLE_USER}" -b --extra-vars "kubeconfig_localhost=true kubectl_localhost=true"
  fi 
  cd ..
  
  sleep 5
  ${kbCtl} --kubeconfig="${vKubeConfig}" get nodes
