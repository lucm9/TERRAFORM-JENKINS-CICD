resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucketname
  acl    = var.acl

  tags = {
    Name = "MyBucket"
  }
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"

    # MFA delete is optional and only supported if versioning is enabled
    # Note: Terraform cannot enable MFA Delete (AWS only supports enabling it via AWS CLI with root account)
    # mfa_delete = "Enabled"  # This is not supported in Terraform
  }
}
