# Set up Kubernetes cluster on Bare-Metal Machines using Tarraform+Kubespray

We will use Terraform + Kubespray to set up the Kubernetes cluster with Portworx on these machines.

### Pre-requisites:
- An installation [shell script](https://github.com/PureStorage-OpenConnect/k8s-px-terraform/blob/main/scripts/prereq.sh) has been shipped in this package. This script will install all required prerequisites softwares/packages for all environments like gcloud/aws/azure/baremetal if they are not already installed. The script is tested on MacOS, CentOS and Ubuntu systems. See the [PreRequisites](https://github.com/PureStorage-OpenConnect/k8s-px-terraform/blob/main/README.md#prerequisites) section on the main readme for more details. If you do not want to install everything, the steps are provided below for the packages required by the current environment only.
- Machines running with CentOS or Ubuntu and the configuration must meet the minimum [requirements for Portworx](https://docs.portworx.com/start-here-installation/). Portworx requires minimum 3 worker nodes to run. All machines must have 4CPUs and 4GB of RAM.
- Additional (unmounted) hard drives attached to the worker nodes for the Portworx storage and kvdb device.
- Disable the firewall so machines can connect to each other (A script is provided for CentOS to disable the firewall). If you do not want to  disable the firewall then you can allow the TCP ports at 9001-9022 and UDP port at 9002. Read the network section for more information in [portworx documentation](https://docs.portworx.com/start-here-installation/).
- You will need to use a machine as controller. This conroller must be able to connect to all the machines with password-less ssh (Steps are provided to setup passwordless ssh).
- The ssh user must be the root user. If you want to use another user account with sudo privileges make sure the user is able to run sudo commands without requiring to enter the password.
- All machines including the controller must have SELinux disabled. If that was enabled and you have disabled it make sure to restart the machines. You can use following commands to check and disable it:
  
  > Note: You will need to run the following commands on each host including the controller one.

	**First SSH to the nodes:**
	
		ssh <user>@<hostname or IP>

	**Then check SELinux:**
	
		getenforce

	**If is not disabled, use these commands to disable and restart the machine:**
	
		setenforce 0
		sed -i --follow-symlinks 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/sysconfig/selinux
		reboot now

## Steps
### 1. Setup the controller:
Conroller is the machine where you will be running all the terraform commands. Here are the steps to prepare it:

> Note: It can be one of the machines you are going to use for kubernetes cluster.
	 
- Login to your controller machine with ssh.
- Install basic utilities:

	**CentOS:**
	
		sudo yum install wget git unzip python3-pip -qy
		
	**Ubuntu:**
	
		sudo apt-get install wget git unzip python3-pip -qy
		
	**macOS:**
	
		brew install wget git unzip python3

- Install Terraform (Versoin: 1.1.4). (Skip if already installed)

	**Linux:**
	 
		wget -q -O/tmp/terraform.zip https://releases.hashicorp.com/terraform/1.1.4/terraform_1.1.4_linux_amd64.zip
		sudo unzip -q -d /usr/bin /tmp/terraform.zip
		
	**macOS:**

	**Verify:**

		terraform -v
		
	Note: The last command `terraform -v` should return the terraform version.  If there is any issue' checkout the [terraform installation guide](https://learn.hashicorp.com/tutorials/terraform/install-cli) as per your environment.
	
- Install kubectl: (Skip if already installed):

		curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
		sudo install -o root -g root -m 0755 kubectl /usr/bin/kubectl
		
- Set environment variables with ssh user and the IP addresses of all the hosts separated by white space. For example if you have 5 machines configured with these IPs '10.21.152.94, 10.21.152.95, 10.21.152.96, 10.21.152.97 and 10.21.152.98' and you are going to use 'root' user, hare are the commands to setup the variables:

		export vHOSTS="10.21.152.94 10.21.152.95 10.21.152.96 10.21.152.97 10.21.152.98";
		export vSSH_USER="root"

- Setup and test password-less ssh:
	Following command will attempt to add your ssh key to the **authorized_keys** file of all your hosts provided in vHOSTS variable. It will ask for the password for each host (once for each host).
	
		for i in $vHOSTS ;do ssh-copy-id ${vSSH_USER}@${i}; done
	
    Test the passwordless ssh.
	
		for i in $vHOSTS ;do ssh ${vSSH_USER}@${i} 'sudo hostname' ; done
	
    This command will print the hostname of each host without asking for the password, wich indicates passwordless ssh is working fine and you have sudo (root) permissions as well.

### 2. Get the Terraform code from the repository
Download the latest source from [git](https://github.com/PureStorage-OpenConnect/k8s-px-terraform.git/) to have latest k8s-px-terraform library. Alternatively, git pull command will bring the latest code if you already have the source code pulled

	git clone https://github.com/PureStorage-OpenConnect/k8s-px-terraform.git

### 3. Setup the environment

Navigate to the 'scripts' folder where all the scripts are saved:

	cd k8s-px-terraform/scripts

**Disable firewall:** If you want to disable the firewall you can use the following script (CentOS machines):
> If you want to check the current status just run without the `--disable` parameter.

	./disable-firewall_CentOS.sh --disable
	
> Note: For Ubuntu, the firewall is open by default and you do not need to run the script for it.

Execute the script to setup environment by replacing values accordingly:

`./setup_env.sh <EnvironmentName> <ClusterName> <Location>`

Example:

    ./setup_env.sh baremetal px-cluster01 ps-lab-01

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

**PX_HOST_IPS** - Hostname and IP of the nodes. This will be pre-configured by the setup-evn.sh script and you can modify if you want.

**PX_ANSIBLE_USER** - This is for the ssh user Kubespray will use. It must be root or a user with sudo privileges who is able run run sudo command without requiring to enter the password. This also will be pre-configured by the setup-env.sh script.

**PX_METALLB_ENABLED** - Set this to true if you want to install the MetalLB as well.

**PX_METALLB_IP_RANGE** - If 'PX_METALLB_ENABLED' is set to true, provide an IP Range for MetalLB from the current network subnet. MetalLB will assign IPs from this range. It will be ignored if  'PX_METALLB_ENABLED' is set to false.

**PX_KUBESPRAY_VERSION** - Set the Kubespray version. Check out available [versions](https://github.com/kubernetes-sigs/kubespray) and click on the branches drop-down menu. You will see branches for differnt releases like **release-2.17**. Note down the available release name you want to use and put here the number only. e.g 2.17

**PX_K8S_VERSION** - Set Kubernetes Version. e.g: "v1.21.6". Leave blank to use the default supported by your selected Kubespray version. Please note that the  version number must be equal to or greater than the minimum suported by Kubespray and it must be less than (not equal to) supported by kubespray for example kubespray 2.18 support v1.22.6 by default and minimum support version is v1.20.0, so you can select any version from v1.20.0 to v1.22.5. If you want to use the v1.22.6 version just leave this variable blank. e.g. "". For other versions use appropriate kubespray version. Check out kubespray [documentation](https://github.com/kubernetes-sigs/kubespray) for more information.

**PX_KUBE_CONTROL_HOSTS** - Specify the number of hosts to be used as Kubernetes control plane nodes.
>NOTE:
>1. Portworx will not use these nodes as storage nodes, so these nodes will be cordoned.
>2. Portworx needs minimum 3 worker nodes, so `TotalNodes - ControlPlaneNodes` must be equal to or greater than 3.

**PX_CLUSTER_NAME** - This variable is to specify the cluster name. This also will be pre-configured by the setup-env.sh script, you can modify if you want.

**PX_OPERATOR_VERSION** - To specify the portworx operator version.

**PX_STORAGE_CLUSTER_VERSION** - To specify the portworx storage cluster version. 
> Note: Make sure version is in 3 digits i.e 2.9.0

**PX_KVDB_DEVICE** - Specify the device for KVDB. Here are the options for this variable:

* A device name: You can provide a device name which must be available on all of the nodes in the cluster. E.g: "/dev/sdb"
* auto: If it is set to 'auto', the smallest blank drive available on each node will be used as kvdb device.
* Leave Blank (e.g. ""): If you leave it blank, the kvdb will share the px storage. But it is recommended to provide a separate device for storing internal KVDB data for production clusters. This allows to separate KVDB I/O from storage I/O.

Once all the variables have been configured, your file will look as the following example:

	# Specify the hostnames and IP of the nodes.
	PX_HOST_IPS="linux-host02.puretec.purestorage.com,10.21.152.94 linux-host03.puretec.purestorage.com,10.21.152.95 linux-host04.puretec.purestorage.com,10.21.152.96 linux-host05.puretec.purestorage.com,10.21.152.97 linux-host06.puretec.purestorage.com,10.21.152.98"

	# Specify the ssh user Ansible will use. It must be root or a sudo user who is able run run sudo command without requiring to the password.
	PX_ANSIBLE_USER="root"

	# Enabled MetalLB load-balancer. If enabled, also provide an IP range from the current subnet.
	# MetalLB will assign IPs from this range. 'PX_METALLB_IP_RANGE' will be ignored if 'PX_METALLB_ENABLED' is set to 'false' 
	PX_METALLB_ENABLED="false"
	PX_METALLB_IP_RANGE="10.21.236.61-10.21.236.70"

	# Set Kubespray Version, Leave blank to use the latest available. e.g: "2.17"
	PX_KUBESPRAY_VERSION="2.18"

	# Set Kubernetes Version, Leave blank to use the default supported by Kubespray. e.g: "v1.21.6"
	PX_K8S_VERSION="v1.22.6"

	# Specify the number of hosts to be used as Kubernetes control plane nodes.
	PX_KUBE_CONTROL_HOSTS=2

	# ClusterName
	PX_CLUSTER_NAME="px-cluster02"

	# Set portworx operator version
	PX_OPERATOR_VERSION="1.6.1"

	# Set portworx storage cluster version. Use Major.Minor.Patch format, e.g: 2.9.0 is valid but 2.9 is not.
	PX_STORAGE_CLUSTER_VERSION="2.7.4"

	# Specify the device for KVDB. If it is set to 'auto', the smallest blank drive available on each node will be used as kvdb device.
	# If you leave it blank, the kvdb will share the px storage.
	PX_KVDB_DEVICE="auto"

### 5. Run the following terraform commands to begin the cluster setup.

> Note: If you are reusing hosts that were previously members of another Kubernetes cluster, be sure to reboot them once.

	terraform init;
	terraform validate;
	terraform plan -out plan.out;
	terraform apply "plan.out";

This will take 10-20 minutes to finish. This completes the creation of kubernetes cluster with Portworx.
> Note: A new kube config file named 'kube-config-file' will be created in your current directory.

### 6. Check if everything is up and ready:
To check nodes:

	kubectl --kubeconfig=kube-config-file get nodes                          

To check portworx pods:

	kubectl --kubeconfig=kube-config-file get pods -n portworx 

If all of the pods are up, next check portworx cluster status:

	PX_NS_AND_POD=$(kubectl --kubeconfig=kube-config-file get pods --no-headers -l name=portworx --all-namespaces -o jsonpath='{.items[*].metadata.ownerReferences[?(@.kind=="StorageCluster")]..name}' -o custom-columns="Col-1:metadata.namespace,Col-2:metadata.name" | head -1)
	kubectl --kubeconfig=kube-config-file exec -n ${PX_NS_AND_POD% *} ${PX_NS_AND_POD#* } -c portworx -- /opt/pwx/bin/pxctl status

## Adding node to the cluster:

To add a new node to the cluster you will need to run `add-node.sh` script. The script exists in the same folder where you ran the terraform commands to create the cluster. So navigate to the folder.

> Note-1: If you are re-adding the host that was previously a member of another Kubernetes cluster, be sure to reboot it once.

> Note-2: The same ssh user will be used which you had provided while setting up the cluster. So make sure it is available on the new node if it was other than the 'root' user.

Here are the steps to add a new node:

* Set variable with the IP of the node you are going to add

		export HOST_IP="<AddIPofNode>";

* Make sure the password-less ssh is setup. If not then run the below commands:

		ssh-copy-id $(. vars;echo $PX_ANSIBLE_USER)@${HOST_IP}

* Test the passwordless ssh.

		ssh -oBatchMode=yes $(. vars;echo $PX_ANSIBLE_USER)@${HOST_IP} 'sudo echo "Its working!"'

* Disable the firewall with following script (For CentOS machines):

		(export vHOSTS=$HOST_IP; export vSSH_USER=$(. vars; echo $PX_ANSIBLE_USER); ../../../../scripts/disable-firewall_CentOS.sh --disable)

* Run the `add-node.sh` script to beging add node process.

		./add-node.sh ${HOST_IP}

* When completed run check if node is available on the cluster:
	
		kubectl --kubeconfig=kube-config-file get nodes
    
## Removing nodes from the cluster:
To remove a node from the cluster you will need to run `remove-node.sh` script. The script exists in the same folder where you ran the terraform commands to create the cluster. So navigate to that folder follow these steps:

* List the nodes and identify node name which you want to remove

		kubectl --kubeconfig=kube-config-file get nodes
* Run remove-node.sh script to remove the node.

		./remove-node.sh <node-name-to-remove>

* This example will remove the specified node from the cluster. Once above script finishes, check the nodes:

		kubectl --kubeconfig=./kube-config-file get nodes

* You will see the node has been removed from the cluster, finally remove the node from the node-groups in the inventory file manually:

		vim "kubespray/inventory/<your cluster name>/hosts.yaml"

	> Make sure to remove the node from all groups.


## Cleanup steps:


> Warning: This process will remove the Kubernetes cluster and wipe the portworx data.

Navigate to the folder where you ran the terraform commands to create the cluster and run following command to destroy the Kubernetes/Portworx cluster:

	terraform destroy -auto-approve;

