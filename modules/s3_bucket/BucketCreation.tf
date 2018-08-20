provider "aws" {
  region  = "us-east-1"
  profile = "aap-sandbox-ea"
  version = "~> 1.19.0"
}

resource "aws_s3_bucket" "bucket" {
  bucket = "${var.SourceBucket}"
  acl    = "private"

  tags {
    Name        = "Intern bucket"
    Environment = "ea"
  }

  versioning {
    enabled = "${var.versioning}"
  }

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }

  lifecycle_rule {
    id      = "log"
    enabled = "${var.lifecycle}"
    prefix  = "test/"

    tags {
      "rule"      = "test"
      "autoclean" = "true"
    }

    transition {
      days          = 2
      storage_class = "GLACIER"
    }

    expiration {
      days = 7
    }
  }
}

/*useful
resource "aws_s3_bucket_object" "object" {
  bucket = "${var.SourceBucket}"
  key    = "Tulips.jpg"
  source = "${var.pathToObject}"
  etag   = "${md5("${var.pathToObject}")}"
}
*/
variable "SNSarn" {}

resource "aws_s3_bucket_notification" "bucket_notification" {
  bucket = "${aws_s3_bucket.bucket.id}"

  topic {
    topic_arn = "${var.SNSarn}"
    events    = ["s3:ObjectCreated:Put"]
  }
}

resource "aws_s3_bucket" "destBucket" {
  bucket = "${var.destBucket}"
  acl    = "private"
}

resource "aws_ssm_parameter" "destBucket" {
  name      = "destBucket"
  type      = "String"
  overwrite = true
  value     = "${var.destBucket}"
}
