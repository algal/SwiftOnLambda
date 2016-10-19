variable "region" {
	type = "string"
	description = "AWS region e.g eu-west-1"
}

variable "environment" {
  type = "string"
  default = "Dev"
}

variable "s3_bucket" {
  type = "string"
}

# path to the lambda function deployment package zip file
variable "lambdazip" {
  type = "string"
}

variable "lambda_function_name" {
  type = "string"
}
