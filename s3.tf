resource "aws_s3_bucket" "b" {
  bucket = "firefly-elm-dev-backup"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "example" {
  bucket = aws_s3_bucket.b.id
  acl    = "public-read-write"
}

resource "aws_iam_role" "ec2_s3_access_role" {
  name               = "s3-role"
  assume_role_policy = "${file("assumerolepolicy.json")}"
}

resource "aws_iam_instance_profile" "test_profile" {                             
name  = "test_profile"
role = "${aws_iam_role.ec2_s3_access_role.name}"
}

resource "aws_iam_policy" "policy" {
  name        = "test-policy"
  description = "A test policy"
  policy      = "${file("policys3bucket.json")}"
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = ["${aws_iam_role.ec2_s3_access_role.name}"]
  policy_arn = "${aws_iam_policy.policy.arn}"
}


terraform {
  backend "s3" {
    bucket = "firefly-elm-dev-terraform"
    key    = "firefly-elm-dev/s3/terraform.tfstat"
    region = "us-east-2"
  }
}

