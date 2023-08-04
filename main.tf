locals {
  prefix                           = var.prefix
  suffix                           = var.suffix
  agentless_scan_ecs_task_role_arn = var.agentless_scan_ecs_task_role_arn
  external_id                      = var.external_id
}

provider "aws" {
  profile = "management"
  region  = "eu-central-1"
}

resource "aws_iam_role" "agentless_scan_snapshot_role" {
  name                 = "${local.prefix}-snapshot-role-${local.suffix}"
  max_session_duration = 43200
  path                 = "/"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          AWS = local.agentless_scan_ecs_task_role_arn
        },
        Condition = {
          StringEquals = {
            "sts:ExternalId" = local.external_id
          }
        }
      },
    ]
  })

  inline_policy {
    name = "LaceworkAgentlessWorkloadSnapshots"
    policy = jsonencode({
      Version = "2012-10-17"
      Statement = [
        {
          Sid      = "DescribeInstances"
          Action   = ["ec2:Describe*"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Sid      = "CreateSnapshots"
          Action   = ["ec2:CreateTags", "ec2:CreateSnapshot"]
          Effect   = "Allow"
          Resource = "*"
        },
        {
          Sid = "SnapshotManagement"
          Action = [
            "ec2:DeleteSnapshot",
            "ec2:ModifySnapshotAttribute",
            "ec2:ResetSnapshotAttribute",
            "ebs:ListChangedBlocks",
            "ebs:ListSnapshotBlocks",
            "ebs:GetSnapshotBlock",
            "ebs:CompleteSnapshot"
          ]
          Effect   = "Allow"
          Resource = "*",
          Condition = {
            StringLike = {
              "aws:ResourceTag/LWTAG_SIDEKICK" = "*"
            }
          }
        },
        {
          Sid    = "SnapshotEncryption"
          Effect = "Allow"
          Action = [
            "kms:DescribeKey",
            "kms:Encrypt",
            "kms:Decrypt",
            "kms:ReEncrypt*",
            "kms:GenerateDataKey*",
            "kms:CreateGrant"
          ]
          Resource = "*"
          Condition = {
            StringLike = {
              "kms:ViaService" = "ec2.*.amazonaws.com"
            }
          }
        },
        {
          Sid      = "OrgPermissions"
          Action   = ["organizations:Describe*", "organizations:List*"]
          Effect   = "Allow"
          Resource = "*"
        },
      ]
    })
  }

  tags = {
    Name                     = "${local.prefix}-task-execution-role"
    LWTAG_SIDEKICK           = "1"
    LWTAG_LACEWORK_AGENTLESS = "1"
  }
}
