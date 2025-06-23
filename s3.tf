resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucketname

  versioning {
    enabled = true
  }

  acl = var.acl
}
