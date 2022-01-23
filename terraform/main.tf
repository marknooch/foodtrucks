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

# create bucket for static website
resource "aws_s3_bucket" "s3_home" {
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# grant access to github-actions AWS account.  In an enterprise setting, I'd look at storing the secret in Vault 
# and then using a gihub action to fetch the secret from vault.  This still has the problem of how does the 
# action authenticate with Vault.  With a hosted runner, we could use environment variables to provision access
# at worst case.  I'd look to use the github jwt option first though.
resource "aws_iam_user" "github-actions" {
  name = "github-actions"
}

# this will need to be updated when we implement CloudFront in #6
data "aws_iam_policy_document" "s3_home_ipd" {
  statement {
    principals {
      type = "*"
      identifiers = [ "*" ]
    }

    actions = [ "s3:GetObject", "s3:GetObjectVersion"]
    resources = ["${aws_s3_bucket.s3_home.arn}/*"]
  }

  statement {
    principals {
      type = "AWS"
      identifiers = [aws_iam_user.github-actions.arn]
    }

    actions = ["s3:*"]
    resources = ["${aws_s3_bucket.s3_home.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "public-read" {
  bucket = aws_s3_bucket.s3_home.id
  policy = data.aws_iam_policy_document.s3_home_ipd.json 
  
}

# populate secrets in repo for github actions account programmatically.
provider "github" {}

data "github_repository" "repo" {
  full_name = "marknooch/foodtrucks"
}

resource "github_actions_secret" "AWS_ACCESS_KEY_ID" {
  repository = data.github_repository.repo.name
  secret_name = "AWS_ACCESS_KEY_ID"
  plaintext_value         = aws_iam_access_key.github-actions.id
}

resource "github_actions_secret" "AWS_SECRET_ACCESS_KEY" {
  repository = data.github_repository.repo.name
  secret_name             = "AWS_SECRET_ACCESS_KEY"
  plaintext_value         = aws_iam_access_key.github-actions.secret
}

# this is a hack.  By doing this I can let the terraform region dictate the region that we use in the github actions.  
# Ideally we'd obtain these non-secret values from the files themselves and avoid this circling back approach I used here.
resource "github_actions_secret" "AWS_REGION" {
  repository = data.github_repository.repo.name
  secret_name             = "AWS_REGION"
  plaintext_value         = var.region
}

resource "github_actions_secret" "S3_BUCKET" {
  repository = data.github_repository.repo.name
  secret_name = "S3_BUCKET"
  plaintext_value = aws_s3_bucket.s3_home.bucket
}