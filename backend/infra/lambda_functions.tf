locals {
  //The name of the lambda function when it is created in AWS
  function_name = "visitor-count"
  //When lambda is run/invoked, run the "handler" function (lambda_handler) from the visitor_count.py file
  handler = "visitor_count.lambda_handler"
  //Run lambda function in python
  runtime = "python3.8"
  //Default timeout is 3 sec. so increase to 5 sec. just in case
  timeout = 5
  //The .zip file to create locally and upload to AWS
  lambda_zip_file = "../lambda/terraform_output/visitor_count.zip"
}

data "archive_file" "dummy" {
  type = "zip"
  output_path = "${local.lambda_zip_file}"

  source {
    content = "hello"
    filename = "dummy.txt"
  }
}

data "aws_iam_policy_document" "assume_role_policy" {
  version = "2012-10-17"

  statement {
    // Let the IAM resource have temporary admin permissions to
    // add permissions for itself.
    // https://docs.aws.amazon.com/STS/latest/APIReference/API_AssumeRole.html
    actions = ["sts:AssumeRole"]
    effect = "Allow"

    // Let the IAM resource manage the (future) lambda resource
    // https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_policies_
    principals {
      identifiers = ["lambda.amazonaws.com"]
      type = "Service"
    }
  }
}

// AssumeRole policy must be separate from other IAM policies
data "aws_iam_policy_document" "func_policy" {
  version = "2012-10-17"

  statement {
    actions = ["dynamodb:Query",
               "dynamodb:UpdateItem"
              ]
    effect = "Allow"
    resources = [aws_dynamodb_table.CRC_Resume_Attr_table.arn]

    
  }
}

resource "aws_iam_role" "default" {
  // Create an IAM resource in AWS which is given the permissions detailed
  // in the above policy document

  assume_role_policy = data.aws_iam_policy_document.assume_role_policy.json
  name = "visitor-counter-func-role"
}

resource "aws_iam_policy" "policy" {
  name = "visitor-count-lambda-policy"
  description = "Policy for the visitor count lambda function"

  policy = data.aws_iam_policy_document.func_policy.json
}

resource "aws_iam_role_policy_attachment" "default" {
  // In addition to letting the IAM resource connect to the (future) lambda
  // function, we also want to let the IAM resource connect to other AWS services
  // like Cloudwatch to see the "print" or "console.log"
  // https://docs.aws.amazon.com/lambda/latest/dg/lambda-intro-execution-role.html

  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.default.name
}

resource "aws_iam_role_policy_attachment" "func_policy" {

  policy_arn = aws_iam_policy.policy.arn
  role = aws_iam_role.default.name
}

resource "aws_lambda_function" "default" {
  filename = local.lambda_zip_file
  function_name = local.function_name
  handler = local.handler
  runtime = local.runtime
  timeout = local.timeout 
  role = aws_iam_role.default.arn // Connect IAM resource to lambda function in AWS
}
