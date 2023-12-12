output "public_ips" {
  value = aws_instance.publicinstance[*].public_ip
}

output "private_ips" {
  value = aws_instance.privateinstance[*].private_ip
}

output "public_ip_bastion" {
  value = aws_instance.bastion[*].public_ip
}

output "public_ip_ansible" {
  value = aws_instance.ansibleinstance[*].public_ip
}

