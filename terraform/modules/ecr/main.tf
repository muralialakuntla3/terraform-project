resource "aws_ecr_repository" "repository" {
  name = var.repository_name
}


resource "aws_ecr_lifecycle_policy" "policy" {
  repository = aws_ecr_repository.repository.name


  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Expire images older than 14 days",
            "selection": {
                "tagStatus": "untagged",
                "countType": "sinceImagePushed",
                "countUnit": "days",
                "countNumber": 14
            },
            "action": {
                "type": "expire"
            }
        },
        {
            "rulePriority": 2,
            "description": "Keep last 30 images",
            "selection": {
                "tagStatus": "tagged",
                "tagPrefixList": ["v"],
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}


data "aws_iam_policy_document" "iam_policy"{
    statement {
    sid    = "EcrAccessPolicy"
    effect = "Allow"

    ###########################
    #Repositories must not be exposed to the public (e.g. Principal:"*" ) due to possible sensitive information that images may contain
    ###########################
    principals {
      type        = "AWS"
      identifiers = ["339263341917"]
    }

    ###########################
    # Repository policy should restrict access to images on a need to know basis to protect possible sensitive information that images may contain
    ###########################
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:PutImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeRepositories",
      "ecr:GetRepositoryPolicy",
      "ecr:ListImages",
      "ecr:DeleteRepository",
      "ecr:BatchDeleteImage",
      "ecr:SetRepositoryPolicy",
      "ecr:DeleteRepositoryPolicy",
    ]
  }
}

resource "aws_ecr_repository_policy" "ecr_policy"{
    repository = aws_ecr_repository.repository.name
    policy = data.aws_iam_policy_document.iam_policy.json
}