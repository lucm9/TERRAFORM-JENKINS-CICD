resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucketname
  acl    = var.acl
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}
