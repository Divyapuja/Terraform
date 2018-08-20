provider "aws" {
  region  = "us-east-1"
  profile = "aap-sandbox-ea"
  version = "~> 1.19.0"
}

resource "aws_iam_role" "roleMoveObject1" {
  name = "roleMoveObject1"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action":["sts:AssumeRole"],
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
  }
  EOF
}

resource "aws_iam_policy" "policyForLambdaStarter1" {
  name        = "policyForLambdaStarter1"
  description = "A policy for Starter Lambda Function"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    }
  ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = "${aws_iam_role.roleMoveObject1.name}"
  policy_arn = "${aws_iam_policy.policyForLambdaStarter1.arn}"
}

/*--------------------------------------------------  LAMBDA  -------------------------------------------------*/
variable "deadQarn" {}

resource "aws_lambda_function" "PythonStarterLambda2" {
  filename      = "modules/PythonLambdaStarter/lambda_function.zip"
  function_name = "PythonStarterLambda2"
  role          = "${aws_iam_role.roleMoveObject1.arn}"
  handler       = "lambda_function.moveFunction_handler"
  runtime       = "python2.7"
  timeout       = 5

  dead_letter_config {
    target_arn = "${var.deadQarn}"
  }
}
