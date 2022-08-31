resource "aws_ecr_repository" "repo" {
  name = "chaewoon/service"
}

resource "aws_ecr_lifecycle_policy" "repo-policy" {
  repository = aws_ecr_repository.repo.name
  policy = <<EOF
  {
    "rules":[
        {
            "rulePriority" : 1,
            "description" : "keep image deployed with tag latest",
            "selection" : {
                "tagStatus" : "tagged",
                "tagPrefixList" : ["latest"],
                "countType" : "imageCountMoreThan",
                "countNumber" : 1
            },
            "action" : {
                "type" : "expire"
            }
        },
        {
            "rulePriority" : 2,
            "description" : "keep last 2 any images",
            "selection" : {
                "tagStatus" : "any",
                "countType" : "imageCountMoreThan",
                "countNumber" : 2
            },
            "action" : {
                "type" : "expire"
            }
        }
    ]
  }
  EOF
}