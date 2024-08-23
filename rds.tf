resource "aws_db_instance" "dbjfc" {
  identifier        = "producciondb"
  engine            = "postgres"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"
  db_name           = "producciondb"
  username  = "pdn"
  password          = "Acc3s0R3m0t0"
  db_subnet_group_name = aws_db_subnet_group.dbjfc.id
  multi_az          = true
 
  tags = {
    Name = "produccion-db"
  }
}

resource "aws_db_subnet_group" "dbjfc" {
  name       = "produccion-db-subnet-group"
  subnet_ids = [aws_subnet.private_subnet_3.id, aws_subnet.private_subnet_4.id]


  }