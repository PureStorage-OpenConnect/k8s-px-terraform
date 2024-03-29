# Step by Step Guide to install Azure AKS with Portworx

> Note-1: If you have completed the AKS admin setup, please go to step #4

## PreRequisite

1. Please see docs/azureAdmin/[README.md](../azureAdmin/README.md) for instruction on installing all the required softwares
   
2. Ensure the Azure user is provisioned with the required permissions to provision
   
3. Have the role added to the user who is about to create the cluster

4. **Important**: To authenticate azure you will need a Service-Principal json file. If you have completed the AKS admin setup then this json file will be created by the script automatically. If you are not an Admin, then you can ask your account admin to provide Service Principal json file and you will need to save this file in **./k8s-px-terraform/scripts/keys/azure-px-ops-service-principal.json**. If you save it somewhere else or the file name is different, the required values will not be populated automatically in terraform configuration file.

### Step 1. Installation of required software

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

### Step 3. Check Azure CLI

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

Make sure the json file **k8s-px-terraform/scripts/keys/azure-px-ops-service-principal.json** is available.

Login using service principal:

> Note: You will find the appid, password and tenant for next command in the service principal json file.

	az login --service-principal -u <appid> --password <password-or-path-to-cert> --tenant <tenant>

view your subscription account:

	az account list -o table
	
Make sure you have your SSH key existing in ~/.ssh/id_rsa 
If the SSH key is not there then you can create it with the following command:
> Note: Do not set any passphrase, just press enter when prompted.

	ssh-keygen

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

> Note: Make sure to update the value of **resource_group** variable each time you create a new cluster
	
```
azure_location                 = "AZURE_LOCATION_ID" //ex: eastus - auto-populates based on the setup_env.sh parameter
resource_group                 = "res-grp"           //Replace this value with your own resource group name. Prepends with px-

cluster_name                   = "pxtest-cluster1"   //First 5 characters cannot contain symbols that are not letters or numbers
k8s_version                    = "1.21.7"
azure_instance_type            = "standard_e4-2ds_v5"
number_of_nodes                = "3"

subscription_id                = "Subscription_ID"  //Reads from az cli login user authentication
service_principle_id           = "SvcPID"           //Reads from keys/service a/c file.
service_principle_key          = "SvcPKEY"          //Reads from keys/service a/c file.
tenant_id                      = "SvcTID"           //Reads from keys/service a/c file.
app_id                         = "SvcAPPID"         //Reads from keys/service a/c file.

px_operator_version            = "1.6.1"
px_kvdb_device_storage_type    = "Premium_LRS"
px_kvdb_device_storage_size    = "150"
px_cloud_storage_size          = "30"
px_cloud_storage_type          = "Premium_LRS"
px_storage_cluster_version     = "2.9.0"
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

1. A new kube config file will be created at ~/.kube/aks_[your-cluster-name].
2. A new ssh pem key file will be downloaded for ssh'ing to the nodes with username "azureuser"

For extra reference you can also take a look at the Microsoft Docs: [here](https://github.com/MicrosoftDocs/azure-docs/blob/master/articles/aks/kubernetes-service-principal.md) </br>

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
	

## Additonal Notes:

### How to SSH into the nodes:

```
- Navigate to the location where the cluster was created. As part of the cluster creation a new pem file gets generated with the cluster name followed by .pem file
- Open your terminal and change directory with command cd, where you downloaded the pem file (from step 6)
- The private key (pem file) must be protected from read and write operations from any other users, SSH will not work in case it is open to read/write by other users
        Command:
                $ chmod 0400 ./<ClusterName>.pem
- To connec to your azure instance/node, enter the following command
        Command:
                $ ssh -i /path/<ClusterName>.pem my-instance-user-name@my-instance-IPv4-address
                $ ssh -i /path/<ClusterName>.pem my-instance-user-name@my-instance-public-dns-name

``` 
