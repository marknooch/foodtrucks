variable "region" {
    description = "AWS region which will host our resources"
    default = "us-east-2"
}

provider "aws" {
  region = var.region
}

data "aws_iam_user" "atlantis" {
  user_name = "atlantis"
}

data "aws_canonical_user_id" "current_user" {}

resource "aws_s3_bucket" "faf-tfstate" {
  bucket = "faf-tfstate"
  versioning {
    enabled = true
  }
  
grant {
    id = data.aws_canonical_user_id.current_user.id
    type = "CanonicalUser"
    permissions = ["FULL_CONTROL"]
  }
  
}

resource "aws_s3_bucket_policy" "atlantis" {
    bucket = aws_s3_bucket.faf-tfstate.id
    policy = data.aws_iam_policy_document.atlantis.json
}

data "aws_iam_policy_document" "atlantis" {
    statement {
        principals {
            type = "AWS"
            identifiers = [data.aws_iam_user.atlantis.id]
        }
        actions = [ "s3:*"]
        resources = [aws_s3_bucket.faf-tfstate.arn]
    }
}