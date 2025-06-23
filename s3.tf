resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucket_name

  versioning {
    enabled = true
  }

  acl = var.acl
}
