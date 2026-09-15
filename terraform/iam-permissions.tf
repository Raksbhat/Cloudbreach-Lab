resource "aws_iam_role_policy" "github_actions_terraform" {
  name = "CloudBreach-Lab-Terraform-Permissions"
  role = aws_iam_role.github_actions_terraform.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "TerraformStateBucket"
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:GetBucketVersioning",
          "s3:GetBucketLocation"
        ]
        Resource = "arn:aws:s3:::cloudbreach-lab-tfstate-972050064174"
      },
      {
        Sid    = "TerraformStateObjects"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:GetObjectVersion",
          "s3:PutObject",
          "s3:DeleteObject"
        ]
        Resource = [
          "arn:aws:s3:::cloudbreach-lab-tfstate-972050064174/cloudbreach-lab/terraform.tfstate",
          "arn:aws:s3:::cloudbreach-lab-tfstate-972050064174/cloudbreach-lab/terraform.tfstate.tflock"
        ]
      },
      {
        Sid    = "TerraformEC2AndVPC"
        Effect = "Allow"
        Action = [
          "ec2:Describe*",
          "ec2:CreateVpc",
          "ec2:ModifyVpcAttribute",
          "ec2:DeleteVpc",
          "ec2:CreateSubnet",
          "ec2:ModifySubnetAttribute",
          "ec2:DeleteSubnet",
          "ec2:CreateInternetGateway",
          "ec2:AttachInternetGateway",
          "ec2:DetachInternetGateway",
          "ec2:DeleteInternetGateway",
          "ec2:CreateRouteTable",
          "ec2:DeleteRouteTable",
          "ec2:CreateRoute",
          "ec2:ReplaceRoute",
          "ec2:DeleteRoute",
          "ec2:AssociateRouteTable",
          "ec2:DisassociateRouteTable",
          "ec2:CreateSecurityGroup",
          "ec2:DeleteSecurityGroup",
          "ec2:AuthorizeSecurityGroupIngress",
          "ec2:RevokeSecurityGroupIngress",
          "ec2:AuthorizeSecurityGroupEgress",
          "ec2:RevokeSecurityGroupEgress",
          "ec2:RunInstances",
          "ec2:TerminateInstances",
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:ModifyInstanceAttribute",
          "ec2:CreateTags",
          "ec2:DeleteTags"
        ]
        Resource = "*"
      },
      {
        Sid    = "TerraformIAMOIDCManagement"
        Effect = "Allow"
        Action = [
          "iam:GetOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
          "iam:UntagOpenIDConnectProvider",
          "iam:GetRole",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:UpdateAssumeRolePolicy",
          "iam:PutRolePolicy",
          "iam:GetRolePolicy",
          "iam:DeleteRolePolicy",
          "iam:ListRolePolicies"
        ]
        Resource = [
          "arn:aws:iam::972050064174:oidc-provider/token.actions.githubusercontent.com",
          "arn:aws:iam::972050064174:role/CloudBreach-GitHubActions-Terraform"
        ]
      }
    ]
  })
}
