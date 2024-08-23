#VPC
resource "aws_vpc" "vpc-infra" {
    cidr_block = "${var.cidr_block}"
    enable_dns_support = true
    enable_dns_hostnames = true

    tags = {
      Name = "produccion"
    }
  
}

#Subredes Publicas

resource "aws_subnet" "subred_publica_1" {
  vpc_id            = aws_vpc.vpc-infra.id
  cidr_block        = "${var.cidr_subnet_publica_1}"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"

  tags = {
    Name = "subred_publica_1"
    
    }

}

resource "aws_subnet" "subred_publica2" {
  vpc_id            = aws_vpc.vpc-infra.id
  cidr_block        = "${var.cidr_subnet_publica_2}"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1b"

   tags = {
    Name = "subred_publica_2"
    
    }
}

#Subredes privadas

resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.vpc-infra.id
  cidr_block        = "${var.cidr_subnet_privada_1}"
  availability_zone = "us-east-1a"

   tags = {
    Name = "subred_privada_1"
    
    }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.vpc-infra.id
  cidr_block        = "${var.cidr_subnet_privada_2}"
  availability_zone = "us-east-1b"

   tags = {
    Name = "subred_privada_2"
    
    }
}

resource "aws_subnet" "private_subnet_3" {
    vpc_id          = aws_vpc.vpc-infra.id
    cidr_block      = "${var.cidr_subnet_privada_3}"
    availability_zone = "us-east-1a"

     tags = {
    Name = "subred_privada_rds_1"
    
    }
 }

 resource "aws_subnet" "private_subnet_4" {
    vpc_id = aws_vpc.vpc-infra.id
    cidr_block = "${var.cidr_subnet_privada_4}"
    availability_zone = "us-east-1b"

     tags = {
    Name = "subred_privada_rds_2"
    
    }
   
 }

#Internet Gateway

 resource "aws_internet_gateway" "IGW_JFK" {
  vpc_id = aws_vpc.vpc-infra.id
     
 }

#Tablas de rutas

resource "aws_route_table" "Tabla_Ruta_Publica" {
  vpc_id = aws_vpc.vpc-infra.id
    route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW_JFK.id
  }
  
}

resource "aws_route_table_association" "asociacion_RT_1" {
  subnet_id = aws_subnet.subred_publica_1.id
  route_table_id = aws_route_table.Tabla_Ruta_Publica.id
  
}
resource "aws_route_table_association" "asociacion_RT_2" {
  subnet_id = aws_subnet.subred_publica2.id
  route_table_id = aws_route_table.Tabla_Ruta_Publica.id
    
}



resource "aws_route_table" "Tabla_Ruta_Privada" {
  vpc_id = aws_vpc.vpc-infra.id
    route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_internet_gateway.IGW_JFK.id
  
  }
   

}

resource "aws_route_table" "Tabla_Ruta_RDS" {
  vpc_id = aws_vpc.vpc-infra.id
    route {
    cidr_block = "0.0.0.0/24"
    gateway_id = aws_internet_gateway.IGW_JFK.id
     
  }
  
}


#Grupos de seguridad

resource "aws_security_group" "SG_JFK" {
  vpc_id = aws_vpc.vpc-infra.id

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

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
}

resource "aws_security_group" "SG_Backend" {
  vpc_id = aws_vpc.vpc-infra.id

   ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
     
     egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  }

  resource "aws_security_group" "SG_RDS" {
  vpc_id = aws_vpc.vpc-infra.id

   ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }
     
     egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  }


 