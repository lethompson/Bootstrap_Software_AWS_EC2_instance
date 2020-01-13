Terraform code to deploy AWS server infrastructure to bootstrap apache, java, jenkins, and terraform software
--------------------------------------------------------------------------------------------------------------


### First create a directory to place all terraform code
```
> mkdir aws_terraform
```

```
> cd aws_terraform
 ```
 
 ### Create the terraform file (main.tf) that contains the code to bootstrap software on AWS server & security group associated with the server

 ```
 > touch main.tf
 ```
 
### main.tf
 ```
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


```
### Create the terraform file (var.tf) to initialize all your variables for the terraform code to deploy the AWS infrastructure

 ```
 > touch var.tf
 ```
 ### var.tf
 
 ```
 variable "region"{
default = "us-east-1"
}

variable "web_server_port" {
default = 80
}

```
 ### Steps to run the terraform code to deploy the AWS Infrastructure
 
 ```
 > terraform init
 ```
 
 ```
 > terraform validate
 ```
 
 ```
 > terraform plan -out=tfplan
 ```
 
 ```
 > terraform apply tfplan
 ```
  ### To destroy the AWS infrastructure deployed from the terraform code
  
 ```
 > terraform destroy
 ```

 ### AWS EC2 instance deployed using the Terraform code

![AWS Bootstrap EC2](https://github.com/lethompson/Bootstrap_Software_AWS_EC2_instance/blob/master/AWS_BootstrapServer_TF.PNG)
 

