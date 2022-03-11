#!/usr/bin/env bash
set -e -u
set -o pipefail
. vars

KS_RELEASE_OPTS="";
if [[ "${PX_KUBESPRAY_VERSION}" != "" ]]; then
  echo "Setting Kubespray version to ${PX_KUBESPRAY_VERSION}."
  KS_RELEASE_OPTS="-b release-${PX_KUBESPRAY_VERSION}"
else
  echo "Using latest available Kubespray version."
fi

if [ ! -d kubespray ]; then
  git clone ${KS_RELEASE_OPTS} https://github.com/kubernetes-sigs/kubespray.git
fi

cd kubespray;
pip3 install -r requirements.txt

declare -a IPS=(${PX_HOST_IPS})

if [ ! -d "inventory/${PX_CLUSTER_NAME}" ]; then
  cp -rfp "inventory/sample" "inventory/${PX_CLUSTER_NAME}"
fi

python3 "contrib/inventory_builder/inventory.py" ${IPS[@]}


if [[ "${PX_K8S_VERSION}" != "" ]]; then
  echo "Setting kubernetes version to ${PX_K8S_VERSION}."
  sed -i_sedtmp "s,^kube_version: .*,kube_version: ${PX_K8S_VERSION},g" inventory/${PX_CLUSTER_NAME}/group_vars/k8s_cluster/k8s-cluster.yml
  rm -f inventory/${PX_CLUSTER_NAME}/group_vars/k8s_cluster/k8s-cluster.yml_sedtmp
else
  echo "Using default supported kubernetes version."
fi

ansible all -i "inventory/${PX_CLUSTER_NAME}/hosts.yaml" -m ping -u"${PX_ANSIBLE_USER}" -b

if [[ "${PX_METALLB_ENABLED}" == "true" ]]; then
  vMETALLB_VARS="{\"metallb_ip_range\": [\"${PX_METALLB_IP_RANGE}\"]}"
  ansible-playbook -i "inventory/${PX_CLUSTER_NAME}/hosts.yaml" "cluster.yml" -u"${PX_ANSIBLE_USER}" -b --extra-vars "kubeconfig_localhost=true kubectl_localhost=true kube_proxy_strict_arp=true metallb_enabled=true" --extra-vars "${vMETALLB_VARS}"
else
  ansible-playbook -i "inventory/${PX_CLUSTER_NAME}/hosts.yaml" "cluster.yml" -u"${PX_ANSIBLE_USER}" -b --extra-vars "kubeconfig_localhost=true kubectl_localhost=true"
fi 

cd ..

if [ -f ~/.kube/config ]; then
  echo "Backing up ~/.kube/config to ~/.kube/config_$(date +%F_%H-%M-%S)"
  mv ~/.kube/config ~/.kube/config_$(date +%F_%H-%M-%S)
fi

mkdir -p ~/.kube
mkdir -p ~/.local/bin
echo "Setting up kubectl and kube-config file..."
cp -f "${kbCtl}"          ~/.local/bin/kubectl
cp -f "${vKubeConfig}"    ~/.kube/config
cp -f "${vKubeConfig}"    ./kube-config-file

sleep 30
