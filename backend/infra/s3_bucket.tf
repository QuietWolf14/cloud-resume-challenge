# Primary bucket
resource "aws_s3_bucket" "fts" {
  bucket = "forevertechstudent.com"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "fts" {
  bucket = aws_s3_bucket.fts.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_website_configuration" "fts" {
  bucket = aws_s3_bucket.fts.id

  index_document {
    suffix = "index.html"
  }
}

data "aws_iam_policy_document" "allow_public_read" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.fts.arn}/*",
    ]
  }
}

# www redirect bucket
resource "aws_s3_bucket" "fts-www" {
  bucket = "www.forevertechstudent.com"
}


resource "aws_s3_bucket_website_configuration" "fts-www" {
  bucket = aws_s3_bucket.fts-www.id

  redirect_all_requests_to {
    host_name = aws_s3_bucket.fts.bucket_domain_name
    protocol = "https"
  }
}
