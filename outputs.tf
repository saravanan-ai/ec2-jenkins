# output "private_key" {
#   value     = nonsensitive(tls_private_key.example.private_key_pem)
#   #sensitive = false
# }

output "public_ip" {
  value = "${aws_instance.ec2_instance.*.public_ip}"
  description = "This is the public IP for VM "
}
