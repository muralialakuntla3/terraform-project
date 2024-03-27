### RDS Instance

resource "aws_db_instance" "default" {
  allocated_storage         = var.allocated_storage
  engine                    = var.engine
  engine_version            = var.engine_version
  instance_class            = var.instance_class
  identifier                = var.identifier
  db_name                   = var.db_name
  username                  = var.username
  password                  = var.password
  multi_az                  = var.multi_az
  backup_retention_period   = var.backup_retention_period
  storage_encrypted         = true #DB cluster encryption must be enabled, Encryption at rest must be enabled for all RDS instances and DB snapshots
  publicly_accessible       = false #Database instance must not allow public accessibility
  copy_tags_to_snapshot     = true #Copy tags to snapshots should be enabled on instances
  vpc_security_group_ids    = var.vpc_security_group_ids
  db_subnet_group_name      = aws_db_subnet_group.subnet_group.id
  skip_final_snapshot = true
  tags = {
    Name = "Muse-Elevar-RDS"
    Project      = var.project
    Terraform    = "true"
    Applicati_CI = var.Applicati_CI
    UAI          = var.UAI
    Email_ID     = var.email_id
  
  }
}

resource "aws_db_subnet_group" "subnet_group" {
  subnet_ids = var.db_subnet_groups

  tags = {
    Name = "RDS DB subnet group"
    Project      = var.project
    Terraform    = "true"
    Applicati_CI = var.Applicati_CI
    UAI          = var.UAI
    Email_ID     = var.email_id
  }
}