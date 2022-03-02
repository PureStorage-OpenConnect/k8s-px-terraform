#!/usr/bin/env bash
set -e -u
set -o pipefail
. vars
cd kubespray;
ansible all -i inventory/${PX_CLUSTER_NAME}/hosts.yaml -m ping -u${PX_ANSIBLE_USER} -b
ansible-playbook -i inventory/${PX_CLUSTER_NAME}/hosts.yaml reset.yml -u${PX_ANSIBLE_USER} -b --extra-vars "reset_confirmation=yes"
