# this is the IAM user that will be used for automated deployments
# e.g. CircleCI, TravisCI, etc.
# NOTE: programmatic access keys will have to be created manually from the 
# AWS console
resource "aws_iam_user" "automation_user" {
  name = "${var.domain}_automation_user"
}

data "aws_iam_policy_document" "automation_user_policy" {
  statement {
    actions = [
      "s3:ListBucket",
    ]

    resources = var.bucket_arns
  }

  statement {
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]

    # TF-UPGRADE-TODO: In Terraform v0.10 and earlier, it was sometimes necessary to
    # force an interpolation expression to be interpreted as a list by wrapping it
    # in an extra set of list brackets. That form was supported for compatibility in
    # v0.11, but is no longer supported in Terraform v0.12.
    #
    # If the expression in the following list itself returns a list, remove the
    # brackets to avoid interpretation as a list of lists. If the expression
    # returns a single list item then leave it as-is and remove this TODO comment.
    resources = [var.bucket_arn]
  }

  statement {
    actions = [
      "cloudfront:CreateInvalidation",
      "cloudfront:ListDistributions",
      "cloudfront:GetDistribution",
    ]

    # CloudFront doesn't yet support resource level permissions
    resources = ["*"]
  }
}

resource "aws_iam_policy" "automation_user_policy" {
  name   = "${var.domain}_automation_user_policy"
  policy = data.aws_iam_policy_document.automation_user_policy.json
}

resource "aws_iam_user_policy_attachment" "automation_user_policy_attachment" {
  user       = aws_iam_user.automation_user.name
  policy_arn = aws_iam_policy.automation_user_policy.arn
}

