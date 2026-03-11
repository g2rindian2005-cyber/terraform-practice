# Account 1 Outputs
output "account1_instance_id" {
  value       = try(aws_instance.ec2_account1[0].id, "Not deployed")
  description = "Instance ID in Account 1"
}

output "account1_public_ip" {
  value       = try(aws_instance.ec2_account1[0].public_ip, "Not deployed")
  description = "Public IP of instance in Account 1"
}

# Account 2 Outputs
output "account2_instance_id" {
  value       = try(aws_instance.ec2_account2[0].id, "Not deployed")
  description = "Instance ID in Account 2"
}

output "account2_public_ip" {
  value       = try(aws_instance.ec2_account2[0].public_ip, "Not deployed")
  description = "Public IP of instance in Account 2"
}