# create bucket for static website
resource "aws_s3_bucket" "s3-home" {
  bucket_prefix = var.bucket-prefix
  acl           = "public-read"

  cors_rule {
    allowed_headers = ["Authorization", "Content-Length"]
    allowed_methods = ["GET", "POST"]
    allowed_origins = ["https://www.${var.domain-name}"]
    max_age_seconds = 3000
  }

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

# this will need to be updated when we implement CloudFront in #6
data "aws_iam_policy_document" "s3-home-ipd" {
  statement {
    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions   = ["s3:GetObject", "s3:GetObjectVersion"]
    resources = ["${aws_s3_bucket.s3-home.arn}/*"]
  }

  statement {
    principals {
      type        = "AWS"
      identifiers = [aws_iam_user.github-actions.arn]
    }

    actions   = ["s3:*"]
    resources = ["${aws_s3_bucket.s3-home.arn}/*"]
  }
}

resource "aws_s3_bucket_policy" "public-read" {
  bucket = aws_s3_bucket.s3-home.id
  policy = data.aws_iam_policy_document.s3-home-ipd.json
}

# S3 bucket for redirecting non-www to www.
resource "aws_s3_bucket" "s3-redirect" {
  bucket_prefix = var.bucket-prefix
  acl           = "public-read"

  website {
    redirect_all_requests_to = "https://www.${var.domain-name}"
  }

}
