locals {
  service_name = "${ var.service_name == "None" ? "" : "-${join("-", split(" ", lower(chomp(var.service_name))))}" }"
  default_name = "${var.project}-${var.environment}${local.service_name}"

  default_tags = {
    Name        = "${var.project}-${var.environment}"
    Environment = "${var.environment}"
    Project     = "${var.project}"
  }
}

// setup SQS queue
resource "aws_sqs_queue" "dead_letter" {
  count = "${ var.module_enabled ? 1 : 0 }"
  name  = "${local.default_name}-dead-letter"

  tags = "${local.default_tags}"
}

data "template_file" "sqs_redrive_policy" {
  count    = "${ var.module_enabled ? 1 : 0 }"
  template = "${file("${path.module}/templates/redrive_policy.json.tpl")}"

  vars {
    dead_letter_queue_arn         = "${aws_sqs_queue.dead_letter.0.arn}"
    dead_letter_max_receive_count = "${var.sqs_dead_letter_redrive_max_receive_count}"
  }
}

data "aws_iam_policy_document" "sqs-allow-send_messages" {
  count = "${ var.module_enabled ? 1 : 0 }"

  statement {
    effect = "Allow"

    actions = [
      "sqs:SendMessage",
    ]

    resources = [
      "${var.notification_source_arns}",
    ]

    principals = {
      type        = "AWS"
      identifiers = ["*"]
    }

    condition = {
      test     = "ArnEquals"
      variable = "aws:SourceArn"
      values   = ["${aws_sns_topic.this.0.arn}"]
    }
  }
}

resource "aws_sqs_queue_policy" "this" {
  count     = "${ var.module_enabled ? 1 : 0 }"
  queue_url = "${aws_sqs_queue.this.0.id}"
  policy    = "${data.aws_iam_policy_document.sqs-allow-send_messages.0.json}"
}

resource "aws_sqs_queue" "this" {
  count          = "${ var.module_enabled ? 1 : 0 }"
  name           = "${local.default_name}"
  redrive_policy = "${data.template_file.sqs_redrive_policy.0.rendered}"

  tags = "${local.default_tags}"
}

// setup SNS topic
resource "aws_sns_topic" "this" {
  count = "${ var.module_enabled ? 1 : 0 }"
  name  = "${local.default_name}"
}

resource "aws_sns_topic_subscription" "this" {
  count     = "${ var.module_enabled ? 1 : 0 }"
  topic_arn = "${aws_sns_topic.this.0.arn}"
  protocol  = "sqs"
  endpoint  = "${aws_sqs_queue.this.0.arn}"
}

data "aws_iam_policy_document" "sns-topic-policy" {
  count = "${ var.module_enabled ? 1 : 0 }"

  statement {
    actions = [
      "SNS:Publish",
    ]

    condition = {
      test     = "ArnLike"
      variable = "aws:SourceArn"
      values   = ["${var.notification_source_arns}"]
    }

    effect = "Allow"

    principals {
      type        = "AWS" //Service
      identifiers = ["*"]
    }

    resources = [
      "${aws_sns_topic.this.0.arn}",
    ]
  }
}

resource "aws_sns_topic_policy" "this" {
  count  = "${ var.module_enabled ? 1 : 0 }"
  arn    = "${aws_sns_topic.this.0.arn}"
  policy = "${data.aws_iam_policy_document.sns-topic-policy.0.json}"
}
