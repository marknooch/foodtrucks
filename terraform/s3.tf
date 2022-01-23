# create bucket for static website
resource "aws_s3_bucket" "s3-home" {
  bucket = var.bucket-name
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }

  policy = templatefile("templates/s3-policy.json", { bucket = "${var.bucket-name}", github-actions-arn = "${aws_iam_user.github-actions.arn}" })

}

# this will need to be updated when we implement CloudFront in #26
# data "aws_iam_policy_document" "s3-home-ipd" {
#   statement {
#     principals {
#       type        = "*"
#       identifiers = ["*"]
#     }

#     actions   = ["s3:GetObject", "s3:GetObjectVersion"]
#     resources = ["${aws_s3_bucket.s3-home.arn}/*"]
#   }

#   statement {
#     principals {
#       type        = "AWS"
#       identifiers = [aws_iam_user.github-actions.arn]
#     }

#     actions   = ["s3:*"]
#     resources = ["${aws_s3_bucket.s3-home.arn}/*"]
#   }
# }

# resource "aws_s3_bucket_policy" "public-read" {
#   bucket = aws_s3_bucket.s3-home.id
#   policy = data.aws_iam_policy_document.s3-home-ipd.json
# }


# S3 bucket for redirecting non-www to www.
resource "aws_s3_bucket" "redirect" {
  bucket = "${var.bucket-name}-redirect"
  acl    = "public-read"
  policy = templatefile("templates/s3-policy.json", { bucket = "${var.bucket-name}", github-actions-arn = "${aws_iam_user.github-actions.arn}" })

  website {
    redirect_all_requests_to = "https://www.${var.domain-name}"
  }

}
