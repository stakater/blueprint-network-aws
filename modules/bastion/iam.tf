resource "aws_iam_instance_profile" "s3_readonly" {
  name = "${var.name}-s3-readonly"
  role = "${aws_iam_role.s3_readonly.name}"
}

resource "aws_iam_role" "s3_readonly" {
  name = "${var.name}-s3-readonly-role"
  path = "/"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "s3_readonly_policy" {
  name = "${var.name}-s3-readonly-policy"
  role = "${aws_iam_role.s3_readonly.id}"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:List*",
                "s3:Get*"
            ],
            "Resource": [
              "${var.s3_bucket_arn}",
              "${var.s3_bucket_arn}/*"
            ]
        }
    ]
}
EOF
}
