#!/usr/bin/env bash
set -e -u
set -o pipefail
. vars

vPXStrgClstrName="px-cluster";
"${kbCtl}"  --kubeconfig="${vKubeConfig}" patch   storagecluster "${vPXStrgClstrName}" --namespace portworx -p '{"spec":{"deleteStrategy":{"type":"UninstallAndWipe"}}}' --type=merge;
"${kbCtl}"  --kubeconfig="${vKubeConfig}" delete  StorageCluster "${vPXStrgClstrName}" --namespace portworx; sleep 10;
"${kbCtl}"  --kubeconfig="${vKubeConfig}" delete  -f "${vPX_Operator_File}"; sleep 60;
