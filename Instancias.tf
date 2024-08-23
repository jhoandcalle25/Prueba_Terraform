#Instancias EC2"
  resource "aws_instance" "Fronted-1" {
  ami           = "ami-04a81a99f5ec58529" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subred_publica_1.id
  security_groups = [aws_security_group.SG_JFK.id]

  tags = {
    Name = "Fronted-1"
  }
}

  resource "aws_instance" "Fronted-2" {
  ami           = "ami-04a81a99f5ec58529" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.subred_publica2.id
  security_groups = [aws_security_group.SG_JFK.id]

  tags = {
    Name = "Fronted-2"
  }
}

 resource "aws_instance" "Backend-1" {
  ami           = "ami-04a81a99f5ec58529" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet_1.id
  security_groups = [aws_security_group.SG_JFK.id]

  tags = {
    Name = "Backend-1"
  }
}

 resource "aws_instance" "Backend-2" {
  ami           = "ami-04a81a99f5ec58529" 
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet_2.id
  security_groups = [aws_security_group.SG_JFK.id]

  tags = {
    Name = "Backend-2"
  }
}

# Grupo de AutoScaling

resource "aws_launch_configuration" "asg_lc" {
  image_id        = "ami-04a81a99f5ec58529"
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.SG_JFK.id]
#  key_name        = aws_key_pair.deployer_key.key_name
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = [aws_subnet.subred_publica_1.id, aws_subnet.subred_publica2.id]
  launch_configuration = aws_launch_configuration.asg_lc.id

  tag {
    key                 = "Name"
    value               = "ASGInstance"
    propagate_at_launch = true
  }
}

# EFS

resource "aws_efs_file_system" "efs_Fronted" {
  creation_token = "efs-token-1"
}

resource "aws_efs_mount_target" "efs_Fronted" {
  file_system_id  = aws_efs_file_system.efs_Fronted.id
  subnet_id       = aws_subnet.subred_publica_1.id
  security_groups = [aws_security_group.SG_JFK.id]
}

resource "aws_efs_file_system" "efs_Backend" {
    creation_token = "efs-token-2"
  
}

resource "aws_efs_mount_target" "efs_Backend" {
    file_system_id = aws_efs_file_system.efs_Backend.id
    subnet_id = aws_subnet.private_subnet_1.id 
    security_groups = [aws_security_group.SG_Backend.id]
}

