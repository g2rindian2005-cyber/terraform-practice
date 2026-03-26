# this is the main terraform file for our lambda function, we will create an IAM role for our lambda function and then attach the AWSLambdaBasicExecutionRole policy to that role, then we will create our lambda function and specify the handler, runtime, and the zip file that contains our lambda function code.
resource "aws_iam_role" "lambda_role" {
  name = "lambda-role"

# this is the trust relationship policy for our lambda function, it allows our lambda function to assume this role and execute with the permissions attached to this role
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

# this is the policy attachment for our lambda function, we are attaching the AWSLambdaBasicExecutionRole policy to our lambda role

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
} 

# this is my lambda function resource, we will create a zip file of our lambda function and then upload it to s3 and then use that s3 bucket to create our lambda function
resource "aws_lambda_function" "function" {
  function_name = "my_lambda_function"

  role = aws_iam_role.lambda_role.arn

  handler = "lambda_function.lambda_handler"

  runtime = "python3.10"

  filename = "lambda_function.zip"

  source_code_hash = filebase64sha256("lambda_function.zip")
}   



# run this command in terminal for zip file
# Tar -a -c -f lambda_function.zip lambda_function.py

