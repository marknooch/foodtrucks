variable "region" {
    description = "AWS region which will host our resources"
    default = "us-east-2"
}

variable "domain-name" {
    description = "domain name which redirects to CloudFront"
    default = "findafoodtruck.ga"
}

variable "tags" {
    description = "tags to apply to the AWS resources"
    default = {
        project = "findafoodtruck"
    }
    type = map(string)
}