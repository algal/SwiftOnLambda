resource "aws_s3_bucket" "s3Bucket" {
    bucket = "${var.s3_bucket}"
    acl = "private"

    tags {
        Name = "${var.s3_bucket}"
        Environment = "${var.environment}"
    }
}

resource "aws_s3_bucket_object" "lambdaPackage" {
    bucket = "${aws_s3_bucket.s3Bucket.bucket}"
    key = "new_object_key"
    source = "${path.module}/${var.lambdazip}"
    etag = "${md5(file("${path.module}/${var.lambdazip}"))}"
}
