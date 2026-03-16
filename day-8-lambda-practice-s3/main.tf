# s3 bucket 
resource "aws_s3_bucket" "bucket" {
  bucket ="gokul-lambda-code-bucket-739013795335"
}

#upoad ZIP code to s3 bucket
resource "aws_s3_object" "lambda_zip" {
  bucket = aws_s3_bucket.bucket.id
  key    = "gokul/lambda_function.zip"
  source = "lambda_function.zip"
  etag = filemd5 ("lambda_function.zip")
}

# iam role for lambda 
resource "aws_iam_role" "lambda_role" {
    name ="lambda_execution_role"
    assume_role_policy = jsonencode({
        Version = "2012-10-17"
        Statement = [{
            Action = "sts:AssumeRole"
            Effect = "Allow"
            Principal = {
                Service = "lambda.amazonaws.com"
            }
        }]
    })
} 


# attach policy to iam role 
 resource "aws_iam_role_policy_attachment" "lambda_policy" {
   role  = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"

 }

 #  this is for lambda s3  read write permissions
  resource "aws_iam_role_policy_attachment" "lambda_s3" {
    role = aws_iam_role.lambda_role.name
    policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  } 


# lambda function
resource "aws_lambda_function" "lambda" { 

   function_name = "my_lambda_function_jawan"
    role = aws_iam_role.lambda_role.arn
    handler ="lambda_function.lambda_handler"
    runtime = "python3.10"

    timeout = 900
    memory_size = 128

    #code pull from s3 (not local)
    s3_bucket = aws_s3_bucket.bucket.id
    s3_key = aws_s3_object.lambda_zip.key
 
 # this is harsh code 
    source_code_hash = filebase64sha256("lambda_function.zip")
}