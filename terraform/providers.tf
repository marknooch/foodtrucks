terraform {
  backend "s3" {
      bucket = "faf-tfstate"
      key = "faf-tfstate"
      region = "us-east-2" # variables are not allowed in backend config
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = var.region
}

provider "github" {}