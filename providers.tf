terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 2.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
}

# Configure the cloudflare Provider
provider "cloudflare" {
}
