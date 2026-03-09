output "public_ip" {
  value = aws_instance.my-ec2.public_ip
}
output "private_ip" {
  value = aws_instance.my-ec2.private_ip
}
output "az" {
  value = aws_instance.my-ec2.availability_zone
}