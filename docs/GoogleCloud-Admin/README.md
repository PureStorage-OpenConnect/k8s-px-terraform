# Step by Step Guide to setup Google Project and Service Account 

## PreRequisite

1. Install all the required softwares/tools - please see docs/[README.md](../../README.md) for instruction on installing all the required softwares
   
2. Ensure the Google Cloud account with Admin User is provisioned, and the required permissions are attached to the admin account
   

## Step 1. Installation of required software

This repo contains scripts/prereq.sh file that will install all the required softwares based on the OS (tested on MacOS and Ubuntu)

Upon running the script the following software/tools will be installed that is required to create AKS cluster

1. GIT
2. Google SDK


For additional details and instructions on above installing above softwares are defined at [readme.md](../../README.md)

### Step 2. Download the IaC code

Download the latest source from [git](https://github.com/PureStorage-OpenConnect/k8s-px-terraform.git) to have latest terraform-iac library

If you already have the repo downloaded, git pull command will bring the latest code from the GIT master

```
    git clone https://github.com/PureStorage-OpenConnect/k8s-px-terraform.git
```

### 3. Execute: GKE Cloud Service Account setup

Execute the script "setup_gcp_project.sh" located in the scripts folder

The script will ask to provide "Billing Account Number" that needs to be associated with the project if you were to choose to select the new project

```
./setup_gcp_project.sh
```

Upon completion of execution, the new keys will be generated in the keys folder, that can be utilized to create the cluster