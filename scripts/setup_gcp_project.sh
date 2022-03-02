#!/bin/bash

if ! command -v gcloud &> /dev/null
then
    echo "The Google Cloud SDK is not installed."
    echo "Please visit https://cloud.google.com/sdk/docs/install for instructions on how to install."
    exit 1
fi

#start the interactive portion to capture user details
echo "This script will help you perform the steps outlined at
https://cloud.google.com/iam/docs/service-accounts

Creates portworx-gke-cloud-operations and portworx-gke-super-admin service-accounts and provides the JSONs

Enter the billing account to be assocaited for the new project :"
read -p "(example: 012345-B765432B-169316):" GCloud_Billing_ID

#log in to gcloud
gcloud init

#capture the project the user selected during log in
PROJECT=$(gcloud config list --format 'value(core.project)')

#create the folder for the keys and set the variable
FOLDER=$(dirname "$0")/keys
mkdir -p -m 700 "$FOLDER"
echo ""
echo "The service account key files will live in $FOLDER/"

# CONNECT='portworx-gke-connect'
# REGISTER='portworx-gke-register'
CLOUDOPS='portworx-gke-cloud-operations'
SUPERADMIN='portworx-gke-super-admin'

#create the needed service accounts
# gcloud iam service-accounts create $CONNECT --project $PROJECT
# gcloud iam service-accounts create $REGISTER --project $PROJECT
gcloud iam service-accounts create $CLOUDOPS --project $PROJECT
gcloud iam service-accounts create $SUPERADMIN --project $PROJECT

#create the needed keys
#gcloud iam service-accounts keys create "$FOLDER"/gcr.json --iam-account  $GCR_SA_EMAIL
# gcloud iam service-accounts keys create "$FOLDER"/register.json --iam-account $REGISTER@$PROJECT.iam.gserviceaccount.com
# gcloud iam service-accounts keys create "$FOLDER"/connect.json --iam-account $CONNECT@$PROJECT.iam.gserviceaccount.com
gcloud iam service-accounts keys create "$FOLDER"/"$PROJECT"-cluster-ops.json --iam-account $CLOUDOPS@$PROJECT.iam.gserviceaccount.com
gcloud iam service-accounts keys create "$FOLDER"/"$PROJECT"-super-admin.json --iam-account $SUPERADMIN@$PROJECT.iam.gserviceaccount.com


#assign the needed IAM roles
# gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$CONNECT@$PROJECT.iam.gserviceaccount.com" --role='roles/gkehub.connect'
# gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$REGISTER@$PROJECT.iam.gserviceaccount.com" --role='roles/gkehub.admin'
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$CLOUDOPS@$PROJECT.iam.gserviceaccount.com" --role='roles/logging.logWriter'
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$CLOUDOPS@$PROJECT.iam.gserviceaccount.com" --role='roles/monitoring.metricWriter'
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$CLOUDOPS@$PROJECT.iam.gserviceaccount.com" --role='roles/stackdriver.resourceMetadata.writer'
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$CLOUDOPS@$PROJECT.iam.gserviceaccount.com" --role='roles/monitoring.dashboardEditor'
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$CLOUDOPS@$PROJECT.iam.gserviceaccount.com" --role='roles/compute.admin'
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$CLOUDOPS@$PROJECT.iam.gserviceaccount.com" --role='roles/container.admin'
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$CLOUDOPS@$PROJECT.iam.gserviceaccount.com" --role='roles/iam.serviceAccountTokenCreator'
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$CLOUDOPS@$PROJECT.iam.gserviceaccount.com" --role='roles/iam.serviceAccountUser'
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$CLOUDOPS@$PROJECT.iam.gserviceaccount.com" --role='roles/resourcemanager.projectIamAdmin'
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$SUPERADMIN@$PROJECT.iam.gserviceaccount.com" --role='roles/iam.serviceAccountAdmin'
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$SUPERADMIN@$PROJECT.iam.gserviceaccount.com" --role='roles/iam.serviceAccountKeyAdmin'
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$SUPERADMIN@$PROJECT.iam.gserviceaccount.com" --role='roles/resourcemanager.projectIamAdmin'
gcloud projects add-iam-policy-binding $PROJECT --member="serviceAccount:$SUPERADMIN@$PROJECT.iam.gserviceaccount.com" --role='roles/editor'


gcloud beta billing projects link $PROJECT --billing-account $GCloud_Billing_ID

#enable the required APIs for the project
gcloud services enable \
    anthos.googleapis.com \
    anthosgke.googleapis.com \
    cloudresourcemanager.googleapis.com \
    container.googleapis.com \
    iam.googleapis.com \
    gkeconnect.googleapis.com \
    gkehub.googleapis.com \
    serviceusage.googleapis.com \
    stackdriver.googleapis.com \
    monitoring.googleapis.com \
    logging.googleapis.com --project $PROJECT
