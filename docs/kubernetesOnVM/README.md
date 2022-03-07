# Set up Kubernetes cluster on Virtual Machines using Tarraform+Kubespray

We will use Terraform + Kubespray to set up the Kubernetes cluster with Portworx on Virtual Machines.

### Pre-requisites:

- Virtual Machines running with CentOS or Ubuntu and the configuration must meet the minimum [requirements for Portworx](https://docs.portworx.com/start-here-installation/). Portworx requires minimum 3 worker nodes to run. All machines must have 4CPUs and 4GB of RAM.
- Additional (unmounted) hard drives attached to the worker nodes for the Portworx storage and kvdb device.
- Disable the firewall so machines can connect to each other (A script is provided for CentOS to disable the firewall). If you do not want to  disable the firewall then you can allow the TCP ports at 9001-9022 and UDP port at 9002. Read the network section for more information in [portworx documentation](https://docs.portworx.com/start-here-installation/).
- You will need to use a machine as controller. This conroller must be able to connect to all the machines with password-less ssh (Steps are provided to setup passwordless ssh).
- The ssh user must be the root user. If you want to use another user with sudo privileges make sure the user is able to run sudo commands without requiring to enter the password.

## Steps
### 1. Setup the controller:
Conroller is the machine you will running the all the commands from. Here are the steps to prepare it:
	 
- Login to your controller machine with ssh.
- Install Terraform (Versoin: 1.1.4). Skip if already installed.
	 
		wget -q -O/tmp/terraform.zip https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_linux_amd64.zip
		unzip -q -d ~/bin /tmp/terraform.zip
		terraform -v

	Note: The last command `terraform -v` should return the terraform version.  If there is any issue checkout the [terraform installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli) as per your environment.
	
- Set an environment variable with ssh user and the IP addresses of all the hosts separated by white space:

		export vHOSTS="192.16.1.94 192.16.1.95 192.16.1.96 192.16.1.97 192.16.1.98";
		export vSSH_USER="root"

- Setup and test password-less ssh:
	Following command will attempt to add your ssh key to the **authorized_keys** file of all your hosts provided in vHOSTS variable. It will ask for the password for each host (once for each host).
	
		for i in $vHOSTS ;do ssh-copy-id ${vSSH_USER}@${i}; done
	
    Test the passwordless ssh.
	
		for i in $vHOSTS ;do ssh ${vSSH_USER}@${i} 'sudo hostname' ; done
	
    This command will print the hostname of each host without asking for the password, wich indicates passwordless ssh is working fine and you have sudo (root) permissions as well.
- Disable firewall:
    If you want to disable the firewall here is a script you can use for the same (Currently CentOS is supported). To access the script you will need to clone this repo as described in the next section:
    Once you cloned the repo you will need to run script as:

        terraform-iac/scripts/vm/disable-firewall_CentOS.sh --disable

> If you want to check the current status just run without the `--disable` parameter.

### 2. Get the Terraform code from the repository
Download the latest source from [git](https://github.com/PureStorage-OpenConnect/k8s-px-terraform.git/) to have latest terraform-iac library. Alternatively, git pull command will bring the latest code if you already have the source code pulled

	git clone https://github.com/PureStorage-OpenConnect/k8s-px-terraform.git.git

### 3. Navigate to the 'scripts' folder and run script to setup the environment.

	cd terraform-iac/scripts
Execute the script to setup environment by replacing values accordingly:

`./setup_env.sh <EnvironmentName> <UniqueIdForTheCluster> <ZoneName>`

Example:

    ./setup_env.sh vm px-cluster01 ps-lab-01

   The script will create directory structure for the project. Once completed you will be in a new shell where you will see files like:

	[user@linux-host02 ps-lab-01]$ ls -la

    total 20
    drwxrwxr-x 2 rbadmin rbadmin  101 Feb 15 03:52 .
    drwxrwxr-x 3 rbadmin rbadmin   23 Feb 15 03:51 ..
    -rwxrwxr-x 1 rbadmin rbadmin 2047 Feb 15 03:51 add-node.sh
    -rwxrwxr-- 1 rbadmin rbadmin 1216 Feb 15 03:51 cluster-config-vars
    -rwxrwxr-x 1 rbadmin rbadmin  658 Feb 15 03:51 main.tf
    -rwxr-xr-x 1 rbadmin rbadmin 2183 Feb 15 03:51 remove-node.sh
    -rwxrwxr-x 1 rbadmin rbadmin  411 Feb 15 03:51 vars

### 4. Change the required variables as per the requirement.
Edit the file `cluster-config-vars` and then set the values for variables as:

**PX_HOST_IPS** - Hostname and IP of the nodes. This will be already set by the setup-evn.sh script.

**PX_ANSIBLE_USER** - This is for the ssh user Kubespray will use. It must be root or a user with sudo privileges who is able run run sudo command without requiring to enter the password. This also will be pre-configured by the setup-env.sh script.

**PX_METALLB_ENABLED** - Set this to true if you want to install the MetalLB as well.

**PX_METALLB_IP_RANGE** - If 'PX_METALLB_ENABLED' is set to true, provide an IP Range for MetalLB from the current network subnet. MetalLB will assign IPs from this range. It will be ignored if  'PX_METALLB_ENABLED' is set to false.

**PX_KUBESPRAY_VERSION** - Set the Kubespray version.

**PX_KUBE_CONTROL_HOSTS** - Specify the number of hosts to be used as Kubernetes control plane nodes. Default is 1, but you can use more than 1 for high availability.
>NOTE:
>1. Portworx will not use these nodes as storage nodes, so these nodes will be cordoned.
>2. Portworx needs minimum 3 worker nodes, so `TotalNodes-ControlPlaneNodes` must be equal to or greater than 3.

**PX_CLUSTER_NAME** - This variable is to specify the cluster name. This also will be pre-configured by the setup-env.sh script.

**PX_OPERATOR_VERSION** - To specify the portworx operator version.

**PX_STORAGE_CLUSTER_VERSION** - To specify the portworx storage cluster version.

**PX_KVDB_DEVICE** - Specify the device for KVDB. Leave blank to share the portworx storage with kvdb. It is recommended to provide a separate device for storing internal KVDB data for production clusters. This allows to separate KVDB I/O from storage I/O.


Once all the variables have been configured, here is an example your file will look alike:

	# Specify the hostnames and IP of the nodes.
	PX_HOST_IPS="linux-host01.puretec.purestorage.com,10.21.152.93 linux-host02.puretec.purestorage.com,10.21.152.94 linux-host03.puretec.purestorage.com,10.21.152.95 linux-host04.puretec.purestorage.com,10.21.152.96 linux-host05.puretec.purestorage.com,10.21.152.97 linux-host06.puretec.purestorage.com,10.21.152.98";
	
	# Specify the ssh user Ansible will use. It must be root or a sudo user who is able run run sudo command without requiring to the password.
	PX_ANSIBLE_USER="root";
	
	# Enabled MetalLB load-balancer.
	PX_METALLB_ENABLED="true"
	PX_METALLB_IP_RANGE="10.21.236.61-10.21.236.70"
	
	# Set Kubespray Version
	PX_KUBESPRAY_VERSION=2.17
	
	# Specify the number of hosts to be used as Kubernetes control plane nodes.
	PX_KUBE_CONTROL_HOSTS=1
	
	# ClusterName
	PX_CLUSTER_NAME="px-cluster01"
	
	# Set portworx operator version
	PX_OPERATOR_VERSION="1.6.1"
	
	# Set portworx storage cluster version
	PX_STORAGE_CLUSTER_VERSION="2.9.0"
	
	# Specify the device for KVDB. Leave blank to share the px storage for kvdb. It is recommended to provide a separate device for storing internal KVDB data for production clusters. This allows to separate KVDB I/O from storage I/O.
	PX_KVDB_DEVICE="/dev/sdb";

### 5. Run the following terraform commands to begin the cluster setup.

	terraform init;
	terraform validate;
	terraform plan -out plan.out;
	terraform apply "plan.out";

This will take 10-20 minutes to finish. This completes the creation of kubernetes cluster with Portworx.
> Note: A new kube config file will be created at ~/.kube/config, and the existing kube config file will be backed up with date and time stamp.

### 6. Once done, check if the cluster is UP.

	kubectl get nodes --kubeconfig=./kube-config-file;
	kubectl get pods -n portworx --kubeconfig=./kube-config-file;

## Adding nodes to the cluster:
To add a new node to the cluster you will need to run `add-node.sh` script. The script exists in the same folder where you ran the terraform commands to create the cluster.

    ./add-node.sh 192.168.1.55
    
This example will add a node with '192.16.1.98' IP to the cluster.
    
## Removing nodes from the cluster:
To remove a node from the cluster you will need to run `remove-node.sh` script. The script exists in the same folder where you ran the terraform commands to create the cluster.

    ./remove-node.sh <node-name-to-remove>
    
This example will remove the specified node from the cluster. Once above script finishes, check the nodes:

    kubectl get nodes --kubeconfig=./kube-config-file

You will see the node has been removed from the cluster, finally remove the node from the node-groups in the inventory file:

    vim "kubespray/inventory/<your cluster name>/hosts.yaml"
    
> Make sure to remove the node from all groups.


## Cleanup steps:


> Warning: This process will remove the Kubernetes cluster and wipe the portworx data.

Navigate to the folder where you ran the terraform commands to create the cluster and run following command to destroy the Kubernetes/Portworx cluster:

	terraform destroy -auto-approve;

