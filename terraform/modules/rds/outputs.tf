output "rds_enpoint" {
  value = aws_db_instance.default.endpoint
}

output "rds_resource_id" {
    value = aws_db_instance.default.resource_id
}
