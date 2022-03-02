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

echo "px_cloud_storage_type: ${px_cloud_storage_type} and ${3}"
echo "px_cloud_storage_size: ${px_cloud_storage_size} and ${4}"

echo "px_kvdb_device_storage_type: ${px_kvdb_device_storage_type} and ${5}"
echo "px_kvdb_device_storage_size : ${px_kvdb_device_storage_size} and ${6}"
echo "Running sed command on the manifest files"
vTmpPXOperator=./1-px-operator.yml;
vTmpPXStorage=./2-storage-cluster.yml;
#cat ../../../../manifests/portworx-gke/1-px-operator.yml | \
#cat ../../../../manifests/portworx-gke/2-storage-cluster.yml | \
cp -f ../../../../manifests/portworx-gke/1-px-operator.yml ${vTmpPXOperator};
cp -f ../../../../manifests/portworx-gke/2-storage-cluster.yml ${vTmpPXStorage};

sed -i_sedtmp "s,<portworx_operator_version_replaceme>,${px_operator_version},g" ${vTmpPXOperator};
sed -i_sedtmp "s,<storage_cluster_version_replaceme>,${px_storage_cluster_version},g" ${vTmpPXStorage};
sed -i_sedtmp "s,<portworx_cloud_storage_type_replaceme>,${px_cloud_storage_type},g" ${vTmpPXStorage};
sed -i_sedtmp "s,<portworx_cloud_storage_size_replaceme>,${px_cloud_storage_size},g" ${vTmpPXStorage};
sed -i_sedtmp "s,<kvdb_device_storage_type_replaceme>,${px_kvdb_device_storage_type},g" ${vTmpPXStorage};
sed -i_sedtmp "s,<kvdb_device_storage_size_replaceme>,${px_kvdb_device_storage_size},g" ${vTmpPXStorage};

rm *_sedtmp

echo "Installing PortWorx Operator"
kubectl apply -f ${vTmpPXOperator} 2>&1 >/dev/null
sleep 30

echo "Installing Portworx storage cluster"
kubectl apply -f ${vTmpPXStorage} 2>&1 >/dev/null; sleep 30;

echo "Creating storage classes"
kubectl apply -f "../../../../manifests/common/storage-classes.yml" ; sleep 30;
