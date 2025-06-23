resource "aws_s3_bucket" "my_bucket" {
  bucket = var.bucketname
  acl    = var.acl
}

resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.my_bucket.id

  versioning_configuration {
    status = "Enabled"
    # NOSONAR - MFA-Delete protection enforced via bucket policy below
    # Native MFA-Delete can only be enabled manually by root user
  }
}

# MFA protection via bucket policy
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
      "s3:DeleteObjectVersion",
      "s3:DeleteObjectTagging",
      "s3:DeleteObjectVersionTagging"
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

resource "aws_s3_bucket_policy" "require_mfa_delete" {
  bucket = aws_s3_bucket.my_bucket.id
  policy = data.aws_iam_policy_document.deny_delete_without_mfa.json
}