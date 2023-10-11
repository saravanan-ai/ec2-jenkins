################################
## AWS Provider Module - Main ##
################################

# AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  access_key = "xx"
  secret_key = "xxx"
  region     = "us-east-1"
}

data "aws_vpc" "my_vpc" {
  id = "xxx" 
}

data "aws_subnet" "my_subnet"{
    id = "xx"
}

# resource "tls_private_key" "example" {
#   algorithm = "RSA"
#   rsa_bits  = 4096
# }

# resource "aws_key_pair" "generated_key" {
#   key_name   = var.key_name
#   public_key = tls_private_key.example.public_key_openssh
# }

resource "aws_instance" "ec2_instance" {
    ami = "${var.ami_id}"
    subnet_id = data.aws_subnet.my_subnet.id
    instance_type = "${var.instance_type}"
    key_name = "testnewlinux"
    vpc_security_group_ids = [aws_security_group.jenkins_security_group.id]
    user_data = <<EOF
#!/bin/bash
# Update the system and install Java (required for Jenkins)

sudo ufw allow 8080
sudo apt-get update -y
sudo apt-get install -y openjdk-11-jdk

# Import Jenkins repository key and add Jenkins repository
curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io.key | sudo tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/ | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null


sudo apt-get update -y

# Install Jenkins
sudo apt-get install -y jenkins

# Start the Jenkins service and enable it to start on boot
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo ufw enable

# Allow Jenkins to execute shell commands (optional)
sudo usermod -aG wheel jenkins

# Print initial admin password (you'll need this to complete Jenkins setup)
echo "Jenkins initial admin password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword

EOF
    associate_public_ip_address = true  # Ensure that this attribute is set to true
    tags = {
    Name = "test-linux"
  }
}

#Create security group 
resource "aws_security_group" "jenkins_security_group" {
  name        = "jenkins_sg20"
  description = "Allow inbound ports 22, 8080"
  vpc_id      = data.aws_vpc.my_vpc.id

  #Allow incoming TCP requests on port 22 from any IP
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
#Allow incoming TCP requests on port 443 from any IP
  ingress {
    description = "Allow HTTPS Traffic"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow incoming TCP requests on port 8080 from any IP
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Allow all outbound requests
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# resource "aws_network_interface_sg_attachment" "sg_attachment" {
#   security_group_id    = aws_security_group.allow_http.id
#   network_interface_id = aws_instance.ec2_instance.primary_network_interface_id
# }
