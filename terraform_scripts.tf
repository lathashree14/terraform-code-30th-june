provider "aws" {
  version = "~> 4.0"
  region  = "ap-south-1"
  access_key = "AKIAZJXRR6OOWJ6SXTO4"
  secret_key = "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"
}

terraform {
  backend "s3" {
    bucket = "bucket-06-july-2023"
    key    = "terraform_scripts.tf"
    region = "us-east-1"
  }
}

#create a VPC 

resource "aws_vpc" "mumbai_vpc1" {
  cidr_block = "10.10.0.0/16"
  tags = {
    Name = "mumbai_vpc1"
  }
}
#creating subnets under mumbai region
resource "aws_subnet" "mumbai-subnet-1a" {
    vpc_id = aws_vpc.mumbai_vpc1.id
    cidr_block = "10.10.0.0/24"
    availability_zone = "ap-south-1a"
  tags = {
    Name = "mumbai-subnet-1a"
  }
}

#creating another subnet under 1a AZ
resource "aws_subnet" "mumbai-subnet-1a1" {
    vpc_id = aws_vpc.mumbai_vpc1.id
    cidr_block = "10.10.1.0/24"
    availability_zone = "ap-south-1a"
  tags = {
    Name = "mumbai-subnet-1a1"
  }
}

#creating subnet 1b
resource "aws_subnet" "mumbai-subnet-1b" {
    vpc_id = aws_vpc.mumbai_vpc1.id
    cidr_block = "10.10.2.0/24"
    availability_zone = "ap-south-1b"
  tags = {
    Name = "mumbai-subnet-1b"
  }
}
#creating another subnet under 1b
resource "aws_subnet" "mumbai-subnet-1b1" {
    vpc_id = aws_vpc.mumbai_vpc1.id
  cidr_block = "10.10.3.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name = "mumbai-subnet-1b1"
  }
}

#creating a ec2 instances in 1a AZ
resource "aws_instance" "mumbai-instance" {
    ami = "ami-0f5ee92e2d63afc18"
    instance_type = "t2.micro"
    key_name = aws_key_pair.mumbai-key-pair.id
  subnet_id = aws_subnet.mumbai-subnet-1a.id
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.mumbai_SG_allow_ssh_http.id]
  tags = {
    Name = "mumbai-instance"
  }
}
########creating a ec2 instances 
resource "aws_instance" "mumbai-instance1" {
    ami = "ami-0f5ee92e2d63afc18"
    instance_type = "t2.micro"
    key_name = aws_key_pair.mumbai-key-pair.id
  subnet_id = aws_subnet.mumbai-subnet-1b.id
  associate_public_ip_address = "true"
  vpc_security_group_ids = [aws_security_group.mumbai_SG_allow_ssh_http.id]
  tags = {
    Name = "mumbai-instance"
  }
}
#creating key-pair
resource "aws_key_pair" "mumbai-key-pair" {
  key_name   = "mumbai-23rd-june"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDJFpe9T0cVkY5aj1r+gVj0FBNlZ+dTDB5fEazxI/HHZTtyIMYH2nPXkJTPqaIUR2Coj/3aj3r9sT0+llluhxY4W/Ss/TCxAjLB0tfzyYeRYWDt7uFQTxzVT0gmJjD68Nc7fK8CLx6nRg83RJfUoCj6mPLesOIG9Hj93mV2REK4MJeOy/gwNvK1xWDZxooKpAHCxcSZz2ug5KhZSAd5mci9bg2J+/JxgG00VwIPBiWky0uq1lBcH39ddjFFWoHFGjDgXK8E6TJTye0AAWZTxTJvTwt2fFgK/bK9i0XNIsHw7xvz+f4CAMcvbrg3E8WvoSUUGWJjS59NkLazFCH9REGI7zOM6VX41W/S9m9GSwlCjwx7uaduJx9jSlaZwTdsP+tcBfmPBmb8G4FhKt68Sd0ad1zcWurzzHlCcAkxkKlcGUGz+QrXKubw1Zyadj+DCCmPqcTBiWLb0Uealw1W5qxiA7cXpktuo4tGQj/TeW7UNoEdE/7wNUrhciyjFXwBMDc= LathaShree@LAPTOP-E9319V5A"
}

##creating a security group
resource "aws_security_group" "mumbai_SG_allow_ssh_http" {
  name        = "allow_ssh_hhtp"
  description = "Allow ssh and http inbound traffic"
  vpc_id      = aws_vpc.mumbai_vpc1.id

  ingress {
    description      = "ssh from pc"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    }

   ingress {
    description      = "http from pc"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    
  }

  tags = {
    Name = "allow_ssh_http"
  }
}
#creating internet-gateway
resource "aws_internet_gateway" "mumbai-IG" {
  vpc_id = aws_vpc.mumbai_vpc1.id
  tags = {
    Name = "mumbai-IG"
  }
}
#creating a route table

resource "aws_route_table" "mumbai_RT" {
  vpc_id = aws_vpc.mumbai_vpc1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.mumbai-IG.id
  }

  tags = {
    Name = "mumbai-RT"
  }
}
resource "aws_route_table_association" "mumbai_RT-Association-1" {
  subnet_id      = aws_subnet.mumbai-subnet-1a.id
  route_table_id = aws_route_table.mumbai_RT.id
}
resource "aws_route_table_association" "mumbai_RT-Association-2" {
  subnet_id      = aws_subnet.mumbai-subnet-1b.id
  route_table_id = aws_route_table.mumbai_RT.id
}
#creating Target group

resource "aws_lb_target_group" "mumbai-lb-tg" {
  name     = "cardwebsite-terraform"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mumbai_vpc1.id
}

#creating Target group attatchment

resource "aws_lb_target_group_attachment" "mumbai-tg-attatchment-1" {
  target_group_arn = aws_lb_target_group.mumbai-lb-tg.arn
  target_id        = aws_instance.mumbai-instance.id
  port             = 80
}

resource "aws_lb_target_group_attachment" "mumbai-tg-attatchment-2" {
  target_group_arn = aws_lb_target_group.mumbai-lb-tg.arn
  target_id        = aws_instance.mumbai-instance1.id
  port             = 80
}

#creating a listner

resource "aws_lb_listener" "mumbai-listner" {
  load_balancer_arn = aws_lb.load-balancer-mumbai.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mumbai-lb-tg.arn
  }
}

#creating a Load Balancer

resource "aws_lb" "load-balancer-mumbai" {
  name               = "cardwebsite-LB-terraform"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mumbai_SG_allow_ssh_http.id]
  subnets            = [aws_subnet.mumbai-subnet-1a.id,aws_subnet.mumbai-subnet-1b.id]
  tags = {
    Environment = "production"
  }
}

#creating launch template 

resource "aws_launch_template" "mumbai_RT" {
  name = "mumbai_RT"
  image_id = "ami-0f5ee92e2d63afc18"
  instance_type = "t2.micro"
  key_name = aws_key_pair.mumbai-key-pair.id
  
  monitoring {
    enabled = true
  }
  placement {
    availability_zone = "us-west-2a"
  }
  vpc_security_group_ids = [aws_security_group.mumbai_SG_allow_ssh_http.id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "mumbai-instance-ASG"
    }
  }

user_data = filebase64("userdata.sh")
}


#creating ASG

resource "aws_autoscaling_group" "mumbai-ASG" {
  vpc_zone_identifier = [aws_subnet.mumbai-subnet-1a.id,aws_subnet.mumbai-subnet-1b.id]
  desired_capacity   = 2
  max_size           = 5
  min_size           = 2

  launch_template {
    id      = aws_launch_template.mumbai_RT.id
    version = "$Latest"
    }
    target_group_arns = [aws_lb_target_group.mumbai-TG-1.arn]
}

#creating ALB TG with ASG

resource "aws_lb_target_group" "mumbai-TG-1" {
  name     = "mumbai-TG-1"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.mumbai_vpc1.id
}

# LB Listener with ASG

resource "aws_lb_listener" "mumbai-listener-1" {
  load_balancer_arn = aws_lb.mumbai-LB-1.arn
  port              = "80"
  protocol          = "HTTP"
 
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.mumbai-TG-1.arn
  }
}
#load balancer with ASG

resource "aws_lb" "mumbai-LB-1" {
  name               = "mumbai-LB-1"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.mumbai_SG_allow_ssh_http.id]
  subnets            = [aws_subnet.mumbai-subnet-1a.id,aws_subnet.mumbai-subnet-1b.id]

  tags = {
    Environment = "production"
  }
}