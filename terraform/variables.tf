variable "region" {
  description = "AWS region which will host our resources"
  default     = "us-east-2"
}

variable "domain-name" {
  description = "domain name which redirects to CloudFront"
  default     = "findafoodtrucknow.ga"
}

variable "tags" {
  description = "tags to apply to the AWS resources"
  default = {
    project = "findafoodtruck"
  }
  type = map(string)
}

variable "bucket-prefix" {
  description = "prefix to use for the bucket names"
  default     = "foodtrucks"
}

variable "github-repo" {
  description = "the repo you create when you fork this one"
  default     = "marknooch/foodtrucks"
}

variable "new" {
  description = "good syntax"
  default     = "new"
}
