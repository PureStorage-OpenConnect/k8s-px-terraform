#!/usr/bin/env bash
set -e -u
set -o pipefail
. vars
cd kubespray;

if [[ "${PX_KVDB_DEVICE}" == "auto" ]]; then 
  ansible-playbook -i "${CONFIG_FILE}" ../kvdb-dev.yaml -u"${PX_ANSIBLE_USER}" -b -e "nodes=all" -e "opr=delete"
fi

ansible all -i inventory/${PX_CLUSTER_NAME}/hosts.yaml -m ping -u${PX_ANSIBLE_USER} -b
ansible-playbook -i inventory/${PX_CLUSTER_NAME}/hosts.yaml reset.yml -u${PX_ANSIBLE_USER} -b --extra-vars "reset_confirmation=yes"
