# create bucket for static website
resource "aws_s3_bucket" "s3_home" {
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
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
