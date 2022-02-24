#!/usr/bin/env bash
set -e -u -x
set -o pipefail

#Installs ArgoCD server to a POD using .kube/config configuration, having ./kube/config is a pre-requisite
kubectl apply -n argocd -f https://gitlab.redblink.net/rbpublic/ps-k8s-manifests/raw/master/argocd/argocd-install.yaml

#Patch the service with argocd-server service-name
kubectl -n argocd patch svc argocd-server -p '{"spec": {"type": "LoadBalancer"}}'

#Prints ArgoCD admin secret, comment out this line if not needed
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

#Sets up argoCD application set controller
kubectl apply -n argocd -f https://gitlab.redblink.net/rbpublic/ps-k8s-manifests/raw/master/argocd/argocd-applicationSet-controller.yaml

#Applying argoCD manifest - to enable image update Controller
kubectl apply -n argocd -f https://gitlab.redblink.net/rbpublic/ps-k8s-manifests/raw/master/argocd/argocd-image-updater.yaml


