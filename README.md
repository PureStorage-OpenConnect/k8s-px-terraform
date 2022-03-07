<img src="icon.png" align="right" />

# Terraform-iac README

> Infrastructure as Code - Terraform to provision Kubernetes on public cloud environments


Terraform-iac contains step by step guide to provision Kubernetes clusters on public code using the terraform code (library) and shell scripts

This repo helps in creating the Kubernetes cluster with Portworx embedded on various cloud providers such as aws, azure, gcloud with portworx installed

## PreRequisites

1. [Installation of AWSCLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html)
2. [Installation of GCloud](https://cloud.google.com/sdk/docs/quickstart)
3. [Installation of Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
4. Your system administrator will have to create accounts on various cloud providers and provide you with the Access Keys (required for creating the clusters)
5. [Install GIT](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git) (required to download this repo)
6. [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli) (Install and basic knowledge on troubleshooting)
7. Portworx - valid license and knowledge
8. [Installation of KubeCtl](https://kubernetes.io/docs/tasks/tools/) (required to manage the Kubernetes cluster)

The installation [shell script](https://github.com/PureStorage-OpenConnect/k8s-px-terraform/blob/master/scripts/prereq.sh) has been shipped in this package. This script will install the above required prerequisites softwares/packages if they are not already installed. The script is tested on MacOS and Ubuntu systems. 

NOTE: Before running the shell script you must clone the git clone under GIT Repo to be able to access the shell script.

To run the shell script you must navigate to the scripts folder and run

``` 
    ./prereq.sh 
```

## GIT Repo
- Clone this repo for accessing the code, scripts and to create the repo
``` 
    git clone https://github.com/PureStorage-OpenConnect/k8s-px-terraform.git
```

## Guides to install Kubernetes with Portworx

- [AWS IAM Policy provisioning Guide](https://github.com/PureStorage-OpenConnect/k8s-px-terraform/blob/master/docs/aws-admin/README.md)
- [AWS Kubenetes + Portworx Setup Guide](https://github.com/PureStorage-OpenConnect/k8s-px-terraform/blob/master/docs/awsEKS/README.md)
- [Google Kubernetes + Portworx Setup Guide](https://github.com/PureStorage-OpenConnect/k8s-px-terraform/blob/master/docs/gcloudGKE/README.md)
- [Azure Kubernetes + Portworx Setup Guide](https://github.com/PureStorage-OpenConnect/k8s-px-terraform/blob/master/docs/AzureAKS/README.md)
- [Virtual Machines Kubernetes + Portworx Setup Guide](https://github.com/PureStorage-OpenConnect/k8s-px-terraform/blob/master/docs/kubernetesOnVM/README.md)
- [Bare Metal Kubernetes + Portworx Setup Guide](https://github.com/PureStorage-OpenConnect/k8s-px-terraform/blob/master/docs/baremetal/README.md)

## References

- Setup AWS Keypair - https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html#having-ec2-create-your-key-pair
- Hashicorp EKS reference - https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/eks_cluster
- Install GCloud SDK Guide - https://cloud.google.com/sdk/docs/quickstart
- Install Azure Cli Guide - https://docs.microsoft.com/en-us/cli/azure/install-azure-cli-macos
- Install and Configure GIT - https://git-scm.com/book/en/v2/Getting-Started-Installing-Git


## Contributing
``` 
    Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change
```

## License

To the extent possible under law, [Purestorage/portworx](https://purestorage.com) has waived all copyright and related or neighboring rights to this work
