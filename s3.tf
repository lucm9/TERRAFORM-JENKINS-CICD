resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucketname
  acl    = var.acl
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status     = "Enabled"
    mfa_delete = "Disabled"  # Explicitly documented
  }
}

# Compensating control: MFA protection via bucket policy
data "aws_iam_policy_document" "deny_delete_without_mfa" {
  statement {
    sid    = "DenyDeleteWithoutMFA"
    effect = "Deny"

    principals {
      type        = "*"
      identifiers = ["*"]
    }

    actions = [
      "s3:DeleteObject",
      "s3:DeleteObjectVersion"
    ]

    resources = [
      "${aws_s3_bucket.my_bucket.arn}/*"
    ]

    condition {
      test     = "Bool"
      variable = "aws:MultiFactorAuthPresent"
      values   = ["false"]
    }
  }
}

# Upload all files in current directory
resource "aws_s3_object" "website_files" {
  for_each = fileset(".", "**")
  
  bucket       = aws_s3_bucket.my_bucket.id
  key          = each.value
  source       = each.value
  content_type = lookup({
    "html" = "text/html"
    "css"  = "text/css"
    "js"   = "application/javascript"
    "tf"   = "text/plain"
    "sh"   = "text/plain"
  }, split(".", each.value)[length(split(".", each.value)) - 1], "application/octet-stream")
  etag = filemd5(each.value)
}

resource "aws_s3_bucket_policy" "require_mfa_delete" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = data.aws_iam_policy_document.deny_delete_without_mfa.json
}