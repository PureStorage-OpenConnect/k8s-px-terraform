# Step by Step Guide to install Azure AKS with Portworx

```
If you have completed the AKS admin setup, please go to step #4

```

## PreRequisite

1. Please see docs/azureAdmin/[README.md](../azureAdmin/README.md) for instruction on installing all the required softwares
   
2. Ensure the Azure user is provisioned with the required permissions to provision
   
3. Have the role added to the user who is about to create the cluster


## Step 1. Installation of required software

This repo contains scripts/prereq.sh file that will install all the required softwares based on the OS (tested on MacOS and Ubuntu)

Upon running the script the following software/tools will be installed that is required to create AKS cluster

1. Terraform
2. GIT
3. Azure CLI
4. Kubectl
5. JQ

For additional details and instructions on above installing above softwares are defined at [readme.md](../../README.md)


### Step 2. Download the IaC code

Download the latest source from [git](https://github.com/PureStorage-OpenConnect/k8s-px-terraform.git) to have latest terraform-iac library

If you already have the repo downloaded, git pull command will bring the latest code from the GIT master

```
    git clone https://github.com/PureStorage-OpenConnect/k8s-px-terraform.git
```

### Step 3. Setup Azure Credentials

```
- run "az version"

Returns the following for example:
~/PureStorage-OpenConnect/k8s-px-terraform/terraform-live/gcloud/rgdev/us-west2 (master) :az version                                                             ✱
{
  "azure-cli": "2.32.0",
  "azure-cli-core": "2.32.0",
  "azure-cli-telemetry": "1.0.6",
  "extensions": {}
}
```

### Login to Azure & Set Subscription

```
#login and follow prompts
az login 

# view and select your subscription account

az account list -o table

Use the below commands when you have more then one subscription

SUBSCRIPTION=<id>
az account set --subscription $SUBSCRIPTION   

```

### Step 4. Navigate to scripts folder and Run setup_env.sh <param1> <param2> <param3>

```
./setup_env.sh <Provider> <AcctID-UniqueIdForCluster> <ZoneName>

~/purestorage/terraform-iac/scripts [master*] :./setup_env.sh help 

You will be be navigated to a new bash shell with all the required files copied and pre-populated

All parameters needs to be entered in "TERRAFORM.TFVARS" file

```
### Step 5. Configure terraform.tfvars [parameters]
	
Please use the below command to find list of Azure regions and availability zones list
	
```	
	 az account list-locations -o table
```
	
Edit the file - vi or nano terraform.tfvars and replace the mandatory parameters to create the cluster
	
```
azure_location                 = "AZURE_LOCATION_ID" //ex: eastus - auto-populates based on the setup_env.sh parameter
resource_group                 = "demo-res-grp"      // prepends with px-

cluster_name                   = "px-test-cluster1"
k8s_version                    = "1.21.7"
azure_instance_type            = "standard_e4-2ds_v5"
number_of_nodes                = "3"

subscription_id                = "6bz78c23-29cd-4567-8ab1-64d120abcd21"
service_principle_id           = "SvcPID"    //reads from az cli login user authentication
service_principle_key          = "SvcPKEY"   //reads from az cli login user authentication
tenant_id                      = "SvcTID"    //reads from az cli login user authentication
app_id                         = "SvcAPPID"  //reads from az cli login user authentication

px_operator_version            = "1.6.1"
px_kvdb_device_storage_type    = "Premium_LRS"
px_kvdb_device_storage_size    = "150"
px_cloud_storage_size          = "30"
px_cloud_storage_type          = "Premium_LRS"
px_storage_cluster_version     = "2.8.1.2"

```

### Step 6. Execute

```
terraform init
terraform validate
terraform plan -var-file="terraform.tfvars" -out plan.out
terraform apply "plan.out"
```

This completes the creation of AKS cluster with Portworx, and the output of cluster name is generated.

Note: 
The following two files are generated:

1. A new kube config file will be created at ~/.kube/config, and the existing kube config file will be backed up with date and time stamp.
2. A new ssh pem key file will be downloaded for ssh'ing to the nodes with username "azureuser"

```
For extra reference you can also take a look at the Microsoft Docs: [here](https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/aks/kubernetes-service-principal.md) </br>
```


###  Step 7. Check if everything is up and ready:

**To check nodes:**

	kubectl --kubeconfig=kube-config-file get nodes                          

**To check portworx pods:**

	kubectl --kubeconfig=kube-config-file get pods -n portworx 

**To check portworx cluster status:**

	PX_NS_AND_POD=$(kubectl --kubeconfig=kube-config-file get pods --no-headers -l name=portworx --all-namespaces -o jsonpath='{.items[*].metadata.ownerReferences[?(@.kind=="StorageCluster")]..name}' -o custom-columns="Col-1:metadata.namespace,Col-2:metadata.name" | head -1)
	kubectl --kubeconfig=kube-config-file exec -n $PX_NS_AND_POD -c portworx -- /opt/pwx/bin/pxctl status

   
## Troubleshooting/Known Issues:

### if your SP key is invalid, generate a new one:

```
SERVICE_PRINCIPAL_SECRET=(az ad sp credential reset --name $SERVICE_PRINCIPAL | jq -r '.password')
```


### Get a kubeconfig for our cluster

```
# use --admin for admin credentials
# use without `--admin` to get no priviledged user.

az aks get-credentials -n <aks-cluster-name> \
--resource-group $RESOURCEGROUP

#grab the config if you want it
cp ~/.kube/config .

```

### How to Apply Portworx Parameter Changes (Re-creates Portworx)

Follow the below steps to apply portworx changes. Modify Terraform.tfvars to accommodate the new changes.

```
For ex:
terraform destroy target null_resource.install_portworx -auto-approve

terraform plan -out "plan.out"
terraform apply "plan.out"
```

## Clean up 

Step 1: 
Configure Kubeconfig to the AKS cluster that you would like to clean up

```
        export KUBECONFIG="$PWD/kube-config-file"

        if the file does not existing run the following to create the kube config file

        az aks get-credentials -n ${var.cluster_name} --resource-group "ps-resource-group"

        Test: 
        kubectl get nodes //should return the nodes
```

Step 2: Delete any other namespaces that may have created on the cluster

Step 3: Authenticate to Azure with the same user when the cluster was created and issue the following commands 

```
terraform destroy -auto-approve

az group delete -n $RESOURCEGROUP
az ad sp delete --id $SERVICE_PRINCIPAL

```
### Destroy specific resource from terraform:

```
terraform destroy target <null_resource.install_portworx> -auto-approve

The Terraform state resource list can be found with the following command
	terraform state list
```

Note: the terraform destroy command needs to be executed from the same location as terraform apply command. 
