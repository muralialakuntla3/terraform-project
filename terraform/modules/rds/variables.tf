variable "allocated_storage" {
  description = "The allocated storage in gibibytes (GiB): 20, 100 ..."
  type = number
  default = 20
}

variable "engine" {
  description = "Database engine to be used: mariadb, mysql, oracle-ee, postgres, sqlserver-ee, aurora ..."
  type = string
  default = "mysql"
}

variable "engine_version" {
  description = "Engine version (optional): 8.0.23, PostgreSQL 13.3-R1 ..."
  type = string
  default = "8.0.36"
}

variable "instance_class" {
  description = "The instance type of the RDS instance (optional): db.t2.micro, db.m6g.large ... "
  type = string
  default = "db.t3.small"
}

variable "identifier" {
  description = "The name of the RDS instance"
  type = string
  default = "muse-elevar-rds-instance"
}

variable "db_name" {
  description = "The name of the database to create (mandatory)"
  type = string
  default = "museelevarDB"
}

variable "username" {
  description = "Username of master DB user"
  type = string
  default = "admin"
}

variable "password" {
  description = "Password for master DB user (This may show up in logs and stored in state file)"
  type = string
  sensitive = true
  default = "admin1234"
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  type = bool
  default = false
}

variable "backup_retention_period" {
  description = "Days to retain backups for: between 0 and 35. 0 indicate backup disabled"
  type = number
  default = 30
} 

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate"
  type = list(string)
  default = [""]
}

variable "db_subnet_groups" {
  description = "List of subnet groups to associate"
  type = list(string)
  default = [""]
}