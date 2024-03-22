output "repository_url" {
  value = aws_ecr_repository.repository.repository_url
}

output "repository_tags"{
    value = aws_ecr_repository.repository.tags
}

output "repository_arn"{
    value = aws_ecr_repository.repository.arn
}