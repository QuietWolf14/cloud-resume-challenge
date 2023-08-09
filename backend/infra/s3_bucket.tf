# Primary bucket
resource "aws_s3_bucket" "fts" {
  bucket = "forevertechstudent.com"
  force_destroy = true
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

resource "aws_s3_bucket_policy" "fts" {
  bucket = aws_s3_bucket.fts.id
  policy = data.aws_iam_policy_document.allow_public_read.json
}

# www redirect bucket
resource "aws_s3_bucket" "fts-www" {
  bucket = "www.forevertechstudent.com"
}

data "aws_iam_policy_document" "allow_public_read_www" {
  statement {
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "${aws_s3_bucket.fts-www.arn}/*",
    ]
  }
}

resource "aws_s3_bucket_public_access_block" "fts-www" {
  bucket = aws_s3_bucket.fts-www.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_policy" "fts-www" {
  bucket = aws_s3_bucket.fts-www.id
  policy = data.aws_iam_policy_document.allow_public_read_www.json
}


resource "aws_s3_bucket_website_configuration" "fts-www" {
  bucket = aws_s3_bucket.fts-www.id

  redirect_all_requests_to {
    host_name = aws_s3_bucket.fts.bucket
    protocol = "http"
  }
}
