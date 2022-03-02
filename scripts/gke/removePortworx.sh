#!/usr/bin/env bash
set -e -u
set -o pipefail

export KUBECONFIG="$PWD/kube-config-file"
vPXStrgClstrName="px-cluster";
kubectl patch  storagecluster ${vPXStrgClstrName} --namespace portworx -p '{"spec":{"deleteStrategy":{"type":"UninstallAndWipe"}}}' --type=merge
kubectl delete StorageCluster ${vPXStrgClstrName} --namespace portworx
sleep 10;

vTmpPXOperator="./1-px-operator.yml";
kubectl delete -f "${vTmpPXOperator}";
sleep 60;

