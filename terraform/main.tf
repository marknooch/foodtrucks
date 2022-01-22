terraform {
  backend "s3" {
      bucket = "faf-tfstate"
      key = "faf-tfstate"
      region = "us-east-2" # variables are not allowed in backend config
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

# grant access to bucket github actions
resource "aws_iam_user" "github-actions" {
  name = "github-actions"
}

resource "aws_iam_access_key" "github-actions" {
  user = aws_iam_user.github-actions.name
}

data "aws_iam_policy_document" "github-actions" {
  statement {
        principals {
            type = "AWS"
            identifiers = [aws_iam_user.github-actions.arn]
        }
        actions = ["s3:*"]
        resources = ["${aws_s3_bucket.s3_home.arn}/*"]
    }
}

resource "aws_s3_bucket_policy" "github-actions" {
  bucket = aws_s3_bucket.s3_home.id
  policy = data.aws_iam_policy_document.github-actions.json
}

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
# I suspect there's a better and more transparent way of doing this.
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