################################################################################
# EKS Module
################################################################################

module "eks" {
  source = "../../../../modules/aws_eks"

  cluster_name    = local.name
  cluster_version = local.cluster_version

  vpc_id          = module.vpc.vpc_id
  subnets         = [module.vpc.private_subnets[0], module.vpc.public_subnets[1]]
  fargate_subnets = [module.vpc.private_subnets[2]]

  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = true

  write_kubeconfig = true
  manage_aws_auth  = true

   node_groups = {
      eks_nodes = {
         desired_capacity     = var.number_of_nodes
         ami_id               = data.aws_ami.purestorage_ami.id
         instance_types       = [ var.ec2_instance_type, ]
         key_name             = var.purestorage_aws_keypair
         max_capacity         = var.number_of_nodes
         min_capacity         = var.number_of_nodes
         asg_tags = [
           {
              key = "Name"
              value = "${local.name}-node-group"
              propagate_at_launch = true
          },
         ]
      }
   }

  tags = {
    ClusterName    = local.name
    GitRepo = "https://github.com/PureStorage-OpenConnect/k8s-px-terraform"
    Reason = "PureStorage-portworx-example"
    CreatedBy = data.aws_caller_identity.current.user_id
  }
}

# SSM policy for bottlerocket control container access
# https://github.com/bottlerocket-os/bottlerocket/blob/develop/QUICKSTART-EKS.md#enabling-ssm
resource "aws_iam_role_policy_attachment" "ssm" {
  role       = module.eks.worker_iam_role_name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

################################################################################
# Kubernetes provider configuration
################################################################################

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

data "aws_ami" "purestorage_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["bottlerocket-aws-k8s-${local.cluster_version}-x86_64-*"]
  }
}

data "aws_caller_identity" "current" {

}


locals {
    name  = (var.cluster_name != "" ? var.cluster_name : "ps-eks-clstr-${random_string.suffix.result}")
    cluster_version = var.k8s_version
}

resource "random_string" "suffix" {
  length  = 4
  special = false
}

resource "tls_private_key" "nodes" {
  algorithm = "RSA"
}
