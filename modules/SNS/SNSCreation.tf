provider "aws" {
  region  = "us-east-1"
  profile = "aap-sandbox-ea"
  version = "~> 1.19.0"
}

/*--------------------------------------------------   SNS2Topic  -----------------------------------------------------*/
resource "aws_sns_topic" "SNS2Topic" {
  name = "SNS2Topic"

  policy = <<POLICY
{
    "Version":"2012-10-17",
    "Statement":[
      {
        "Effect": "Allow",
        "Principal": {"AWS": "*"},
        "Action": [
          "SNS:Publish",
          "SNS:RemovePermission",
          "SNS:SetTopicAttributes",
          "SNS:DeleteTopic",
          "SNS:ListSubscriptionsByTopic",
          "SNS:GetTopicAttributes",
          "SNS:Receive",
          "SNS:AddPermission",
          "SNS:Subscribe"
        ],
        "Resource": "arn:aws:sns:us-east-1:070976655252:SNS2Topic",
        "Condition":{
          "StringEquals": {"AWS:SourceOwner": "070976655252"}
        }
      },
      {
        "Sid": "SNSPublish",
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": "SNS:Publish",
        "Resource": "arn:aws:sns:us-east-1:070976655252:SNS2Topic"
      },
      {
        "Sid": "SNSSubscribe",
        "Effect": "Allow",
        "Principal": {
          "AWS": "*"
        },
        "Action": [
          "SNS:Subscribe",
          "SNS:Receive"
        ],
        "Resource": "arn:aws:sns:us-east-1:070976655252:SNS2Topic"
      }
    ]
}
POLICY
}

/*---------------------------------------------------   SQS   ----------------------------------------------------------*/
resource "aws_sqs_queue" "terraform_queue" {
  name                      = "SNS-SQS"
  delay_seconds             = 0
  max_message_size          = 262144
  message_retention_seconds = 345600
  receive_wait_time_seconds = 0

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Id": "SNS-SQS/SQSDefaultPolicy",
  "Statement": [
    {
      "Sid": "SidSNSSQS",
      "Effect": "Allow",
      "Principal": "*",
      "Action": [
        "SQS:ReceiveMessage",
        "SQS:SendMessage"
      ],
      "Resource": "arn:aws:sqs:us-east-1:070976655252:SNS-SQS"
    },
    {
      "Sid": "SidSNSSQS2",
      "Effect": "Allow",
      "Principal": {
        "AWS": "*"
      },
      "Action": "SQS:SendMessage",
      "Resource": "arn:aws:sqs:us-east-1:070976655252:SNS-SQS",
      "Condition": {
        "ArnEquals": {
          "aws:SourceArn": "${aws_sns_topic.SNS2Topic.arn}"
        }
      }
    }
  ]
}
  EOF
}

resource "aws_sqs_queue" "DeadLetterQueue" {
  name = "DeadLetterQueue"
}

resource "aws_sqs_queue" "SuccessQueue" {
  name = "SuccessQueue"
}

resource "aws_sqs_queue" "FailQueue" {
  name = "FailQueue"
}

/*---------------------------------------  SNS subscription to SQS and LAMBDA --------------------------------------------*/
resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = "${aws_sns_topic.SNS2Topic.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.terraform_queue.arn}"
}

resource "aws_lambda_permission" "with_sns" {
  statement_id  = "AllowExecutionFromSNS"
  action        = "lambda:InvokeFunction"
  function_name = "${aws_lambda_function.wrapperLambda2.function_name}"
  principal     = "sns.amazonaws.com"
  source_arn    = "${aws_sns_topic.SNS2Topic.arn}"
}

/* ----------------------------------------   Role and Policy for Wrapper Lambda   ---------------------------------------*/
resource "aws_iam_role" "wrapperRole2" {
  name = "wrapperRole2"

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

resource "aws_iam_policy" "policy" {
  name        = "ConsolidatedPolicy1"
  description = "A policy for Wrapper Lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": ["lambda:InvokeFunction"],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "states:*",
      "Resource": "*"
    },
    {
      "Action": [
        "sqs:SendMessage"
      ],
      "Effect": "Allow",
      "Resource": "${aws_sqs_queue.DeadLetterQueue.arn}"
    }
  ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "policy-attach" {
  role       = "${aws_iam_role.wrapperRole2.name}"
  policy_arn = "${aws_iam_policy.policy.arn}"
}

/*--------------------------------------------  WRAPPER  LAMBDA  -----------------------------------------------*/
resource "aws_lambda_function" "wrapperLambda2" {
  filename      = "modules/SNS/lambda_function.zip"
  function_name = "wrapperLambda2"
  role          = "${aws_iam_role.wrapperRole2.arn}"
  handler       = "lambda_function.lambda_handler"
  runtime       = "python2.7"

  dead_letter_config {
    target_arn = "${aws_sqs_queue.DeadLetterQueue.arn}"
  }
}

resource "aws_sns_topic_subscription" "user_updates_lambda_target" {
  topic_arn = "${aws_sns_topic.SNS2Topic.arn}"
  protocol  = "lambda"
  endpoint  = "${aws_lambda_function.wrapperLambda2.arn}"
}

/*----------------------------------   Role and Policy for Step Function   -------------------------------------*/
resource "aws_iam_role" "roleforSM2" {
  name        = "roleForSM"
  description = "A role for Step Function"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action":"sts:AssumeRole",
      "Principal": {
        "Service": "states.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
  }
  EOF
}

resource "aws_iam_policy" "policyForSM" {
  name        = "policyForSM"
  description = "A policy for Step Function"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": "*",
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": "states:*",
      "Resource": "*"
    }
  ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "policy-role-attach" {
  role       = "${aws_iam_role.roleforSM2.name}"
  policy_arn = "${aws_iam_policy.policyForSM.arn}"
}

/*------------------------------------------------- STEP FUNCTION  ------------------------------------------*/
variable "moveFunctionArn" {}

resource "aws_sfn_state_machine" "SMforPython2" {
  name     = "SMforPython2"
  role_arn = "${aws_iam_role.roleforSM2.arn}"

  definition = <<EOF
{
  "Comment": "Step function containing AWS Lambda function to transfer S3 object",
  "StartAt": "${var.lambdaToAttach}",
  "States": {
    "${var.lambdaToAttach}": {
      "Type": "Task",
      "Resource": "${var.moveFunctionArn}",
      "End": true
    }
  }
}
EOF
}
