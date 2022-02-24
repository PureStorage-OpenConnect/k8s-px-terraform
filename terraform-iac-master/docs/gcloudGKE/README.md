# Step by Step Guide to install Google Cloud GKE with Portworx

## PreRequisite

1. Install all the required softwares/tools - please see docs/[README.md](../../README.md) for instruction on installing all the required softwares

2. Please see docs/GoogleCloud-Admin/README.md for instruction on provisioning the Google Cloud IAM service account with required permissions for creating the cluster

3. Export the JSON and provide it to the user who is creating the cluster


## Step 1. Installation of required software

This repo contains scripts/prereq.sh file that will install all the required softwares based on the OS (tested on MacOS and Ubuntu)

Upon running the script the following software/tools will be installed that is required to create AKS cluster

1. Terraform
2. GIT
3. Google SDK
4. Kubectl

For additional details and instructions on above installing above softwares are defined at [readme.md](../../README.md)

### Step 2. Download the IaC code

Download the latest source from [git](https://github.com/PureStorage-OpenConnect/k8s-px-terraform.git) to have latest terraform-iac library

If you already have the repo downloaded, git pull command will bring the latest code from the GIT master

```
    git clone https://github.com/PureStorage-OpenConnect/k8s-px-terraform.git
```

### 3. GKE Cloud Authorization

```
Create a new Service Account (if you do not have one provisioned) already :
Navigate to Google cloud console for your org (https://console.cloud.google.com/) - Login with your credentials
Navigate to IAM & Admin 
Click on Service Accounts
    Create new Service Account if you dont have one
    Choose Name (for ex: svcPortworxDemo )
        Permissions: 
          1. Compute Admin
          2. Service Account User
          3. Kubernetes Engine Admin
          4. Project IAM Admin
          5. Service Account Token Creator
        Keys:
            For the new service account created, Generate a new Key and export the JSON file using Manage Key option under Actions.(this will be used in terraform.tfvars)
    Ensure you are connecting to the service account
        1. gcloud auth revoke <Revoke all active authentications>
        2. gcloud init (choose your servive-account, project-id, region, zone etc)
        2. gcloud auth activate-service-account --key-file=/Users/t_gadar/Downloads/svcPortworxDemo-credentials-52bc683c4a93.json
    
```
### 4. Navigate to scripts folder and Run setup_env.sh <param1> <param2> <param3>

```
./setup_env.sh <Provider> <UniqueIdForCluster> <ZoneName>

./setup_env.sh help

GCloud for example: ./setup_env.sh gcloud <AccountIdWithEnv> us-east4

>Provider : aws, gcloud or zure.
>UniqueIdForCluster : It can be account number or project name.
>Zone : Zone in which cluster will be deployed.


 ~/PureStorage-OpenConnect/k8s-px-terraform/scripts (master) ⚡ :pwd
/Users/t_gadar/PureStorage-OpenConnect/k8s-px-terraform/scripts

 gcloud example:
 ~/PureStorage-OpenConnect/k8s-px-terraform/scripts (master) ⚡ :./setup_env.sh gcloud PSGcloudDev us-central1
 
```

You will be be navigated to a new bash shell at the targeted location with the following files

The following entries are example, you should be seeing similar files and folder structure relative to where you have installed the terraform-iac git repo


#### GCloud Example:
```
terraform-iac/terraform-live/gcloud/PSGcloudDev/us-central1 git/master*
 ~/PureStorage-OpenConnect/k8s-px-terraform/terraform-live/gcloud/PSGcloudDev/us-central1 git:(master*) :ls -alrt
drwxr-xr-x  3 t_gadar  staff    96 Jan 12 23:18 ..
-rw-r--r--  1 t_gadar  staff   571 Jan 12 23:21 terraform.tfvars
-rw-r--r--  1 t_gadar  staff  2244 Jan 24 23:01 gke.tf
-rw-r--r--  1 t_gadar  staff   153 Jan 24 23:01 provider.tf
-rw-r--r--  1 t_gadar  staff  1244 Jan 24 23:01 variable.tf
-rw-r--r--  1 t_gadar  staff   158 Jan 24 23:01 versions.tf
-rw-r--r--  1 t_gadar  staff   444 Jan 24 23:01 vpc.tf
drwxr-xr-x  8 t_gadar  staff   256 Jan 24 23:01 .

```


### 5. Configure terraform.tfvars [parameters]

```
google_cloud_project_id         = "px_project"
google_region                   = "us-central1"  //for VPC only
google_zone                     = "us-central1-a" //If you provide region here, GKE will try create nodes in each zone - Multiplied by 3
number_of_nodes                 = "3"
gke_machine_type                = "e2-standard-2"
compute_engine_service_account  = "portworx-gke-cloud-operations@px-final-test1.iam.gserviceaccount.com"
gcloud_iam_file_location        = "../../../../scripts/keys/px-final-test1-cluster-ops.json"

cluster_name                    = "ps-final-test1"
gke_machine_image               = "UBUNTU_CONTAINERD"
k8s_version                     = "1.21.6-gke.1500"
px_operator_version             = "1.6.1"
px_kvdb_device_storage_type     = "pd-ssd"
px_kvdb_device_storage_size     = "30"
px_cloud_storage_size           = "30"
px_cloud_storage_type           = "pd-ssd"
px_storage_cluster_version      = "2.9.0"

```

### 6. Execute

```
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars" -out plan.out
terraform apply "plan.out"
```

This completes the creation of GKE cluster with Portworx, and the output of cluster name is generated.
Note: A new kube config file will be created at ~/.kube/config, and the existing kube config file will be backed up with date and time stamp.


## Cleanup steps:
Step 1: 
Configure Kubeconfig to the GKE cluster that you would like to clean up

```
        export KUBECONFIG="$PWD/kube-config-file"

        if the file does not existing run the following to create the kube config file

        gcloud container clusters get-credentials --region ${var.google_zone} ${var.cluster_name}

        Test: 
        kubectl get nodes //should return the nodes
```

Step 2: Delete any other namespaces that may have created on the cluster


Step 3: Google Cloud auth

Authenticate to Google Cloud with account provisioned the GKE cluster
```
terraform destroy -auto-approve
```

Note: the terraform destroy command needs to be executed from the same location as terraform apply command. 