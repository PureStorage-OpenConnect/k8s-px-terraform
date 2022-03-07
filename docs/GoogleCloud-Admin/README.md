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

Reference to the log file during one of the setup run: https://raw.githubusercontent.com/PureStorage-OpenConnect/k8s-px-terraform/main/docs/GoogleCloud-Admin/Setup.log?token=GHSAT0AAAAAABRTTPWKJWYGRN2FI3WAYHVSYROVFRQ

The below script will ask for billing id and project id. Both of these can be found from the Google console. See image 1 and image 2.

#### Location of billing id
![Location of billing id](https://github.com/PureStorage-OpenConnect/k8s-px-terraform/blob/main/docs/GoogleCloud-Admin/gcp1.JPG) 


#### Location of project id
![Location of project id](https://github.com/PureStorage-OpenConnect/k8s-px-terraform/blob/main/docs/GoogleCloud-Admin/gcp2.JPG)

```
./setup_gcp_project.sh
```

Upon completion of execution, the new key will be generated in the scripts/keys folder, that should be utilized to create the cluster

```
~/purestorage/terraform-iac/scripts/keys  on master ! :ls -alrt                                      
total 8
-rw-------   1 t_gadar  staff  2355 Feb 23 15:13 px-final-test1-cluster-ops.json
drwxr-xr-x  22 t_gadar  staff   704 Mar  4 09:22 ..
drwx------   3 t_gadar  staff    96 Mar  6 18:39 .
 ~/purestorage/terraform-iac/scripts/keys  on master ! :                                               
 ```
#### Service account with permissions

![alt text](https://github.com/PureStorage-OpenConnect/k8s-px-terraform/blob/main/docs/GoogleCloud-Admin/gcp3.JPG "Service account with permissions") 
