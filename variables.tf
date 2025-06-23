variable "aws_region" {
  description = "The AWS region to create things in."
  default     = "us-east-2"
}

variable "instance_type" {
  description = "instance type for ec2"
  default     = "t2.medium"
}
variable "ami_id" {
  description = "AMI for Ubuntu Ec2 instance"
  default     = "ami-0d1b5a8c13042c939"
}
variable "bucketname" {
  description = "The name of the S3 bucket to create"
  type        = string
  default     = "jenkinscicd-533267047415-cloud"
}

variable "acl" {
  description = "The ACL (Access Control List) for the S3 bucket"
  type        = string
  default     = "private"
}
