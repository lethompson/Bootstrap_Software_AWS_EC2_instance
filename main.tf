provider "aws" {
region = "${var.region}"
access_key = "<AWS ACCESS KEY>"
secret_key = "<AWS SECRET KEY>"

}

resource "aws_instance" "myfirstec2" {
ami = "ami-0c322300a1dd5dc79"
instance_type = "t2.micro"
vpc_security_group_ids = ["${aws_security_group.instance.id}"]
key_name = "<ALREADY CREATED PEM FILE ON AWS>"
user_data = <<EOF
#!/bin/bash
yum update -y
yum -y install java-11-openjdk-devel
rpm --import https://jenkins-ci.org/redhat/jenkins-ci.org.key
yum -y install wget
wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
yum -y install jenkins
yum install httpd -y
yum install unzip -y
sudo wget https://releases.hashicorp.com/terraform/0.11.14/terraform_0.11.14_linux_amd64.zip
unzip terraform_0.11.14_linux_amd64.zip -d /usr/local/bin/
service enable jenkins
service jenkins start
service enable httpd
service httpd start
echo "Welcome to my Jenkins EC2 instance Web Server" > /var/www/html/index.html
chmod 666 /var/www/html/index.html
EOF

tags = {
  Name = "Web-Server-Jenkins-TF"
  Purpose = "Bootstrap in EC2 server: apache, Java, Jenkins, Terraform_v0.11.14"
  Platform = "Linux RHEL 8"
}

}

resource "aws_security_group" "instance" {
   name = "terraform-security-group"

   # Inbound HTTP from anywhere
   ingress {
     from_port   = "${var.web_server_port}"
     to_port     = "${var.web_server_port}"
     protocol    = "tcp"
     cidr_blocks = ["0.0.0.0/0"]

   }

   ingress {
      from_port = 22
      to_port   = 22
      protocol  = "tcp"
      cidr_blocks = ["0.0.0.0/0"]

   }

   ingress {
     from_port = 443
     to_port   = 443
     protocol  = "tcp"
     cidr_blocks = ["0.0.0.0/0"]

   }

   ingress {
     from_port = 8080
     to_port   = 8080
     protocol  = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
   }

   egress {
     from_port   = 0
     to_port     = 0
     protocol    = "-1"
     cidr_blocks = ["0.0.0.0/0"]

   }
}
