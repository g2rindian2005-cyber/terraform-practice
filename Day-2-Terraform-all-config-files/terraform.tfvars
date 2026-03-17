# AWS Region (same for both accounts)
aws_region = "us-east-1"

# AMI and Instance Configuration
#ami_id        = "ami-02dfbd4ff395f2a1b"
#@instance_type = "t2.micro"

# Account IDs
account1_id = "123456789012"  # Replace with your Account 1 ID
account2_id = "987654321098"  # Replace with your Account 2 ID

# AWS CLI Profiles for authentication
profile_account1 = "account1"  # Replace with your Account 1 profile
profile_account2 = "account2"  # Replace with your Account 2 profile

# Deploy flags - set to true to deploy to each account
deploy_to_account1 = true
deploy_to_account2 = false