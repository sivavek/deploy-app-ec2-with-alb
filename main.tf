resource "aws_vpc" "ac-vpc" {
  cidr_block = var.cidr
  tags = {
    Name = "ac-vpc"
  }
}

resource "aws_subnet" "ac-subnet1" {
  vpc_id            = aws_vpc.ac-vpc.id
  cidr_block        = var.sub1_cidr
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "ac-subnet1"
  }
}

resource "aws_subnet" "ac-subnet2" {
  vpc_id            = aws_vpc.ac-vpc.id
  cidr_block        = var.sub2_cidr
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "ac-subnet2"
  }
}

resource "aws_internet_gateway" "ac-igw" {
  vpc_id = aws_vpc.ac-vpc.id
  tags = {
    Name = "ac-igw"
  }

}

resource "aws_route_table" "ac-rt" {
  vpc_id = aws_vpc.ac-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ac-igw.id
  }
  depends_on = [aws_internet_gateway.ac-igw]
  tags = {
    Name = "ac-rt"
  }
}

resource "aws_route_table_association" "ac-rt-assoc1" {
  subnet_id      = aws_subnet.ac-subnet1.id
  route_table_id = aws_route_table.ac-rt.id
}
resource "aws_route_table_association" "ac-rt-assoc2" {
  subnet_id      = aws_subnet.ac-subnet2.id
  route_table_id = aws_route_table.ac-rt.id
}
resource "aws_security_group" "ac-sg" {
  vpc_id      = aws_vpc.ac-vpc.id
  name        = "ac-sg"
  description = "Allow all inbound and outbound traffic"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "ac-sg"
  }
}
resource "aws_instance" "ac-instance" {
  ami             = "ami-0261755bbcb8c4a84" # Replace with a valid AMI ID for your region
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.ac-subnet1.id
  vpc_security_group_ids = [aws_security_group.ac-sg.id]
  associate_public_ip_address = true
  user_data       = file("userdata.sh") # Ensure you have a user data script named userdata.sh in the same directory
  tags = {
    Name = "ac-instance"
  }
}
resource "aws_instance" "ac-instance2" {
  ami             = "ami-0261755bbcb8c4a84" # Replace with a valid AMI ID for your region
  instance_type   = "t2.micro"
  subnet_id       = aws_subnet.ac-subnet2.id
  vpc_security_group_ids = [aws_security_group.ac-sg.id]
  associate_public_ip_address = true
  user_data       = file("userdata1.sh") # Ensure you have a user data script named userdata.sh in the same directory
  tags = {
    Name = "ac-instance2"
  }
}

resource "aws_alb" "ac-alb" {
  name               = "ac-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.ac-sg.id]
  subnets            = [aws_subnet.ac-subnet1.id, aws_subnet.ac-subnet2.id]

  tags = {
    Name = "ac-alb"
  }

}
resource "aws_alb_target_group" "ac-tg" {
  name     = "ac-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.ac-vpc.id

  health_check {
    path                = "/"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name = "ac-tg"
  }
}
resource "aws_alb_listener" "ac-listener" {
  load_balancer_arn = aws_alb.ac-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ac-tg.arn
  }

  tags = {
    Name = "ac-listener"
  }
}

resource "aws_alb_target_group_attachment" "ac-tg-attachment1" {
  target_group_arn = aws_alb_target_group.ac-tg.arn
  target_id        = aws_instance.ac-instance.id
  port             = 80
}
resource "aws_alb_target_group_attachment" "ac-tg-attachment2" {
  target_group_arn = aws_alb_target_group.ac-tg.arn
  target_id        = aws_instance.ac-instance2.id
  port             = 80
}

