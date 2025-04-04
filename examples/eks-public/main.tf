/**
 * Copyright (c) 2017-present SIGHUP s.r.l All rights reserved.
 * Use of this source code is governed by a BSD-style
 * license that can be found in the LICENSE file.
 */

terraform {
  required_version = "~> 1.4"
  required_providers {
    local    = "~> 2.4.0"
    null     = "~> 3.2.1"
    aws      = "~> 5.33"
    external = "~> 2.3.1"
  }
}

provider "aws" {
  region = "eu-west-1"
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.fury_public_example.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.fury_public_example.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.fury_public_example.token
  load_config_file       = false
}

data "aws_eks_cluster" "fury_public_example" {
  name = module.fury_public_example.cluster_id
}

data "aws_eks_cluster_auth" "fury_public_example" {
  name = module.fury_public_example.cluster_id
}

data "terraform_remote_state" "vpc" {
  backend = "local"
  config = {
    path = "${path.root}/../vpc/terraform.tfstate"
  }
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

module "fury_public_example" {
  source = "../../modules/eks"

  cluster_name               = var.cluster_name # make sure to use the same name you used in the VPC and VPN module
  cluster_version            = "1.29"
  cluster_log_retention_days = 1

  # availability_zone_names = ["eu-west-1a", "eu-west-1b"]
  subnets = data.terraform_remote_state.vpc.outputs.private_subnets
  vpc_id  = data.terraform_remote_state.vpc.outputs.vpc_id

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = false

  ssh_public_key = tls_private_key.ssh.public_key_openssh

  node_pools = [
    {
      name : "m5-node-pool-self-managed"
      version : null # To use same value as cluster_version
      min_size : 1
      max_size : 2
      instance_type : "m5.large"
      volume_size : 100
      subnets : null
      target_group_arns : null
      container_runtime = "containerd"
      additional_firewall_rules : {
        cidr_blocks = [
          {
            name : "Debug 1"
            type : "ingress"
            cidr_blocks : ["0.0.0.0/0"]
            protocol : "TCP"
            from_port : 80
            to_port : 80
            tags : {
              hello : "tag"
              cluster-tags : "my-value-OVERRIDE-1"
            }
          }
        ]
      }
      labels : {
        "node.kubernetes.io/role" : "app"
        "sighup.io/fury-release" : "v1.25.0"
      }
      taints : []
      tags : {
        "node-tags" : "exists"
      }
      # max_pods : null # To use default EKS setting set it to null or do not set it
    },
    {
      name : "m5-node-pool-spot-self-managed"
      min_size : 1
      max_size : 2
      instance_type : "m5.large"
      spot_instance : true # optionally create spot instances
      # ami_id : "ami-01eb5348cab8e4902" # optionally define a custom AMI
      volume_size : 100
      container_runtime = "docker"
      additional_firewall_rules : {
        cidr_blocks = [
          {
            name : "Debug 2"
            type : "ingress"
            cidr_blocks : ["0.0.0.0/0"]
            protocol : "TCP"
            from_port : 80
            to_port : 80
            tags : {
              hello : "tag"
              cluster-tags : "my-value-OVERRIDE-2"
            }
          }
        ]
      }
      labels : {
        "node.kubernetes.io/role" : "app"
        "sighup.io/fury-release" : "v1.25.0"
      }
      tags : {
        "node-tags" : "exists"
      }
      max_pods : 35
    },
    {
      name : "m5-node-pool-min-config-self-managed"
      min_size : 1
      max_size : 2
      instance_type : "m5.large"
      volume_size : 20
    },
    {
      name : "m5-node-pool-alinux2023-self-managed"
      min_size : 1
      max_size : 2
      ami_type: "alinux2023"
      instance_type : "m5.large"
      volume_size : 20
    },
    {
      name : "m5-node-pool-null-config-self-managed"
      ami_id : null
      version : null
      min_size : 1
      max_size : 2
      instance_type : "m5.large"
      container_runtime : null
      spot_instance : null
      max_pods : null
      volume_size : 100
      subnets : null
      labels : null
      taints : null
      tags : null
      additional_firewall_rules : null
    },
    {
      name : "m5-node-pool-arm64-self-managed"
      min_size : 1
      max_size : 2
      instance_type : "t4g.large"
      volume_size : 20
    },
    {
      type : "eks-managed"
      name : "m5-node-pool-eks-managed"
      min_size : 1
      max_size : 2
      instance_type : "m5.large"
      subnets : null
      labels : {
        "node.kubernetes.io/role" : "app"
        "sighup.io/fury-release" : "v1.25.0"
      }
      taints : []
      tags : {
        "node-tags" : "exists"
      }
    },
    {
      type : "eks-managed"
      name : "m5-node-pool-arm64-eks-managed"
      min_size : 1
      max_size : 2
      instance_type : "t4g.large"
      spot_instance : true # optionally create spot instances
      subnets : null
      labels : {
        "node.kubernetes.io/role" : "app"
        "sighup.io/fury-release" : "v1.25.0"
      }
      taints : []
      tags : {
        "node-tags" : "exists"
      }
    },
    {
      type : "eks-managed"
      name : "m5-node-pool-alinux2023-arm64-eks-managed"
      min_size : 1
      max_size : 2
      ami_type: "alinux2023"
      instance_type : "t4g.large"
      spot_instance : true # optionally create spot instances
      subnets : null
      labels : {
        "node.kubernetes.io/role" : "app"
        "sighup.io/fury-release" : "v1.25.0"
      }
      taints : []
      tags : {
        "node-tags" : "exists"
      }
    },
    {
      type : "eks-managed"
      name : "m5-node-pool-alinux2023-eks-managed"
      min_size : 1
      max_size : 2
      ami_type: "alinux2023"
      instance_type : "m5.large"
      spot_instance : true # optionally create spot instances
      subnets : null
      labels : {
        "node.kubernetes.io/role" : "app"
        "sighup.io/fury-release" : "v1.25.0"
      }
      taints : []
      tags : {
        "node-tags" : "exists"
      }
    }
  ]

  tags = {
    Environment : "kfd-development"
  }

  eks_map_users             = []
  eks_map_roles             = []
  eks_map_accounts          = []
  cluster_enabled_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}
