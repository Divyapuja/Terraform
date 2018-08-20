output "deadQarn" {
  value = "${aws_sqs_queue.DeadLetterQueue.arn}"
}

output "SNSarn" {
  value = "${aws_sns_topic.SNS2Topic.arn}"
}
