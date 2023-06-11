# Primary bucket
resource "aws_s3_bucket" "fts" {
  bucket = "forevertechstudent.com"
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
