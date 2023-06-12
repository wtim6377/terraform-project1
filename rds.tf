# Create an RDS database (Aurora Serverless)
resource "aws_rds_cluster" "rds_cluster" {
  cluster_identifier     = "web-db-cluster"
  engine                 = "aurora-mysql"
  engine_mode            = "provisioned"
  engine_version         = "8.0"
  master_username        = "admin"
  master_password        = "admin123"
  database_name          = "wordpress"
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.aws_db_subnet_group.name
  skip_final_snapshot    = true
  serverlessv2_scaling_configuration {
    max_capacity = 2
    min_capacity = 0.5
  }
}
resource "aws_rds_cluster_instance" "rds_cluster" {
  cluster_identifier = aws_rds_cluster.rds_cluster.cluster_identifier
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.rds_cluster.engine
  engine_version     = aws_rds_cluster.rds_cluster.engine_version

}
resource "aws_db_subnet_group" "aws_db_subnet_group" {
  name       = "aws_db_subnet_group"
  subnet_ids = [aws_subnet.subnet5.id, aws_subnet.subnet6.id]
}

# Create a security group for the RDS database
resource "aws_security_group" "rds_sg" {
  name        = "rds_sg"
  description = "RDS database security group"

  vpc_id = aws_vpc.main.id

  # Allow incoming traffic from the web servers
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Subnet CIDR blocks
  }

  # Allow outgoing traffic to the web servers
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Subnet CIDR blocks
  }
}
