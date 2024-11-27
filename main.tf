provider "aws" {
  region = "us-east-1" 
}
resource "aws_s3_bucket_public_access_block" "public_policy" {
  bucket = aws_s3_bucket.static_site.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket" "static_site" {
  bucket = "fitzgerald-24bbd57a-eab0-d34d-d336-6a71d5ec6da0" 
  tags = {
    Name = "StaticWebsite"
  }
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.static_site.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_policy" "public_access" {
  bucket = aws_s3_bucket.static_site.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "${aws_s3_bucket.static_site.arn}/*"
      }
    ]
  })
}

resource "aws_s3_object" "files" {
  for_each = fileset("./files", "*") # Assumes files are in the './files' directory
  bucket   = aws_s3_bucket.static_site.id
  key      = each.value
  source   = "${path.module}/files/${each.value}"
}

output "bucket_url" {
  value = aws_s3_bucket_website_configuration.website_config.website_endpoint
}
