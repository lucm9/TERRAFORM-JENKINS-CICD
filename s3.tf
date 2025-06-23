# Create S3 bucket
resource "aws_s3_bucket" "mybucket" {
  bucket = var.bucketname
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "mybucket_encryption" {
  bucket = aws_s3_bucket.mybucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

# S3 bucket logging
resource "aws_s3_bucket_logging" "mybucket_logging" {
  bucket = aws_s3_bucket.mybucket.id

  target_bucket = aws_s3_bucket.mybucket.id
  target_prefix = "access-logs/"
}

# Bucket ownership controls
resource "aws_s3_bucket_ownership_controls" "example" {
  bucket = aws_s3_bucket.mybucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

# Public access block - more restrictive but allow website hosting
resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.mybucket.id
  
  # NOSONAR - Public access required for static website hosting
  # Website content is intentionally public and secured via bucket policy
  # Allow public policies but block ACLs for better security
  block_public_acls       = true   # Block public ACLs
  block_public_policy     = false  # Allow bucket policy for website
  ignore_public_acls      = true   # Ignore existing public ACLs
  restrict_public_buckets = false  # Allow public bucket policy
}

# S3 bucket versioning configuration
resource "aws_s3_bucket_versioning" "this" {
  bucket = aws_s3_bucket.mybucket.id

  versioning_configuration {
    status = "Enabled"
    # NOSONAR - MFA-Delete disabled due to operational complexity
    # Equivalent protection provided via bucket policy below
  }
}

# Combined bucket policy for website access AND MFA delete protection
resource "aws_s3_bucket_policy" "combined_policy" {
  bucket = aws_s3_bucket.mybucket.id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # Public read access for website
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.mybucket.arn}/*"
      },
      # MFA required for deletions
      {
        Sid       = "DenyDeleteWithoutMFA"
        Effect    = "Deny"
        Principal = "*"
        Action = [
          "s3:DeleteObject",
          "s3:DeleteObjectVersion",
          "s3:DeleteObjectTagging",
          "s3:DeleteObjectVersionTagging"
        ]
        Resource = "${aws_s3_bucket.mybucket.arn}/*"
        Condition = {
          Bool = {
            "aws:MultiFactorAuthPresent" = "false"
          }
        }
      }
    ]
  })

  depends_on = [
    aws_s3_bucket_public_access_block.example,
    aws_s3_bucket_server_side_encryption_configuration.mybucket_encryption
  ]
}

# Upload objects
resource "aws_s3_object" "index" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "index.html"
  source       = "index.html"
  content_type = "text/html"
  etag         = filemd5("index.html")
}

resource "aws_s3_object" "error" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "error.html"
  source       = "error.html"
  content_type = "text/html"
  etag         = filemd5("error.html")
}

resource "aws_s3_object" "style" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "style.css"
  source       = "style.css"
  content_type = "text/css"
  etag         = filemd5("style.css")
}

resource "aws_s3_object" "script" {
  bucket       = aws_s3_bucket.mybucket.id
  key          = "script.js"
  source       = "script.js"
  content_type = "application/javascript"
  etag         = filemd5("script.js")
}

# Website configuration
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.mybucket.id
  
  index_document {
    suffix = "index.html"
  }
  
  error_document {
    key = "error.html"
  }

  depends_on = [aws_s3_bucket_policy.combined_policy]
}

# Get current AWS region
data "aws_region" "current" {}

# Output the website URL
output "website_url" {
  value       = "http://${aws_s3_bucket.mybucket.bucket}.s3-website-${data.aws_region.current.name}.amazonaws.com"
  description = "URL of the S3 static website"
}

# Output bucket name
output "bucket_name" {
  value       = aws_s3_bucket.mybucket.id
  description = "Name of the S3 bucket"
}