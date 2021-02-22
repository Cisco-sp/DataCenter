output "public_ip_ec2_epg1" {
  value = aws_instance.ec2_epg1.public_ip
}

output "public_ip_ec2_epg2" {
  value = aws_instance.ec2_epg2.public_ip
}

output "private_ip_ec2_epg1" {
  value = aws_instance.ec2_epg1.private_ip
}

output "private_ip_ec2_epg2" {
  value = aws_instance.ec2_epg2.private_ip
}