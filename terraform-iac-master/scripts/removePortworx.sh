#!/usr/bin/env bash
#set -e -u -x
#set -o pipefail

#Remove the Portworx storage cluster. 
kubectl delete -f ../manifests/portworx-eks/2-storage-cluster.yml

#Remove the PortWorx operator
kubectl delete -f ../manifests/portworx-eks/1-px-operator.yml
sleep 30

#Remove the AWS-Secret
kubectl delete -f ../manifests/portworx-eks/0-aws-access-secret.yml

