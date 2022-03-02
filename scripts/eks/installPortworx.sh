#!/usr/bin/env bash
set -e +u
set -o pipefail
export KUBECONFIG="$PWD/kube-config-file"
px_operator_version=$1
px_storage_cluster_version=$2
px_cloud_storage_type=$3
px_cloud_storage_size=$4
px_kvdb_device_storage_type=$5
px_kvdb_device_storage_size=$6

#Installs PortWorx Operator on EKS cluster
vTmpAccfile=./0-aws-access-secret.yml;
cp -f ../../../../manifests/portworx-eks/0-aws-access-secret.yml ${vTmpAccfile};

if [ -z ${AWS_ACCESS_KEY_ID} ]; then 
   echo "AWS keys are not set, reading from the current profile..."; 
   export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
   export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
else 
   echo "var is set to '$var'"; 
fi

sed -ie "s,XXXX_AWS_ACCESS_KEY_ID_XXXX,$(echo -n ${AWS_ACCESS_KEY_ID}|base64),g" ${vTmpAccfile};
sed -ie "s,XXXX_AWS_SECRET_ACCESS_KEY_XXXX,$(echo -n ${AWS_SECRET_ACCESS_KEY}|base64),g" ${vTmpAccfile};

kubectl apply -f ${vTmpAccfile};

vTmpPXOperator=./1-px-operator.yml;
vTmpPXStorage=./2-storage-cluster.yml;
cp -f ../../../../manifests/portworx-eks/1-px-operator.yml ${vTmpPXOperator};
cp -f ../../../../manifests/portworx-eks/2-storage-cluster.yml ${vTmpPXStorage};

sed -i_sedtmp "s,<portworx_operator_version_replaceme>,${px_operator_version},g" ${vTmpPXOperator};
sed -i_sedtmp "s,<storage_cluster_version_replaceme>,${px_storage_cluster_version},g" ${vTmpPXStorage};
sed -i_sedtmp "s,<portworx_cloud_storage_type_replaceme>,${px_cloud_storage_type},g" ${vTmpPXStorage};
sed -i_sedtmp "s,<portworx_cloud_storage_size_replaceme>,${px_cloud_storage_size},g" ${vTmpPXStorage};
sed -i_sedtmp "s,<kvdb_device_storage_type_replaceme>,${px_kvdb_device_storage_type},g" ${vTmpPXStorage};
sed -i_sedtmp "s,<kvdb_device_storage_size_replaceme>,${px_kvdb_device_storage_size},g" ${vTmpPXStorage};

rm *_sedtmp

echo "Installing PortWorx Operator"
kubectl apply -f ${vTmpPXOperator}; 2>&1 >/dev/null

sleep 30

echo "Installing Portworx storage cluster"
kubectl apply -f ${vTmpPXStorage}; 2>&1 >/dev/null

echo "Creating storage classes"
kubectl apply -f "../../../../manifests/common/storage-classes.yml" ; sleep 30;
