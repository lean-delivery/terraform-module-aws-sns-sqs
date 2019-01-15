output "sns_topic_arn" {
  value       = "${element(concat(aws_sns_topic.this.*.arn, list("")), 0)}"
  description = "SNS topic ARN"
}

output "sqs_queue_url" {
  value       = "${element(concat(aws_sqs_queue.this.*.id, list("")), 0)}"
  description = "SQS queue URL"
}
