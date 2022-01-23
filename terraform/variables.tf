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

variable "bucket-name" {
  description = "bucket name; must be globally unique; necessary because some stuff is only known after apply and I haven't found a way to reference that in a template json file"
  default     = "foodtrucks20220123172537018100000001"
}
