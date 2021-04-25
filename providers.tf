terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.22.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.0"
    }
  }
}

# Configure the AWS provider
provider "aws" {
}

# Configure the ibm cloud provider
provider "ibm" {
}


# Configure the cloudflare provider
provider "cloudflare" {
}

# Configure kuberentes provider based on IBM Cloud data
provider "kubernetes" {
  host                   = data.ibm_container_cluster_config.dj_cluster.host
  client_certificate     = data.ibm_container_cluster_config.dj_cluster.admin_certificate
  client_key             = data.ibm_container_cluster_config.dj_cluster.admin_key
  cluster_ca_certificate = data.ibm_container_cluster_config.dj_cluster.ca_certificate
}
