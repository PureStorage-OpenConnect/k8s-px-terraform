#!/bin/bash

if [ -z "$1" ]
  then
    echo "Arg 1: Region is expected"
fi

eks_cluster_name = `$(terraform output -json eks_name | jq -r)`

echo $eks_cluster_name

aws eks --region $1 update-kubeconfig --name "$eks_cluster_name"
