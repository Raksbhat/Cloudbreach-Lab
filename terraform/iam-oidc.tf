resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    Name      = "github-actions-oidc"
    Project   = "CloudBreach-Lab"
    ManagedBy = "Terraform"
  }
}

resource "aws_iam_role" "github_actions_terraform" {
  name        = "CloudBreach-GitHubActions-Terraform"
  description = "Terraform role assumed by CloudBreach-Lab GitHub Actions through OIDC"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "GitHubActionsOIDC"
        Effect = "Allow"

        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }

        Action = "sts:AssumeRoleWithWebIdentity"

        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }

          StringLike = {
            "token.actions.githubusercontent.com:sub" = [
              "repo:Raksbhat/Cloudbreach-Lab:*",
              "repo:Raksbhat@*/Cloudbreach-Lab@*:ref:refs/heads/main"
            ]
          }
        }
      }
    ]
  })

  tags = {
    Project   = "CloudBreach-Lab"
    ManagedBy = "Terraform"
  }
}