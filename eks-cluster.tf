# EKS CLUSTER CONFIG
# defines the eks cluster module,
# creates worker nodes and defines their size/clones
# imports subnets


module "eks" {
  source          = "terraform-aws-modules/eks/aws"
  cluster_name    = local.cluster_name
  cluster_version = "1.20"
  subnets         = module.vpc.private_subnets

  tags = {
    Environment = "development"
    GithubRepo  = "terraform-aws-eks"
    GithubOrg   = "terraform-aws-modules"
  }


  vpc_id = module.vpc.vpc_id

  workers_group_defaults = {
    root_volume_type = "gp2"
  }

cluster_endpoint_private_access = "true"
  cluster_endpoint_public_access  = "true"

  write_kubeconfig      = true
  manage_aws_auth       = true

  worker_groups = [
    {
      name                          = "primary-worker-group"
      instance_type                 = "t2.micro"
      additional_userdata           = "echo test data for primary worker group"
      asg_desired_capacity          = 4
      additional_security_group_ids = [aws_security_group.primary_worker_group.id]
    },
    {
      name                          = "secondary-worker-group"
      instance_type                 = "t2.small"
      additional_userdata           = "echo test data for secondary worker group"
      additional_security_group_ids = [aws_security_group.secondary_worker_group.id]
      asg_desired_capacity          = 8
    },
  ]
}

data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
