resource "aws_s3_bucket" "guide-tfe-es-s3" {
  bucket = var.bucket_name

  tags = {
    Name = var.bucket_name
  }
}

locals {
  bucket_name = aws_s3_bucket.guide-tfe-es-s3.id
}

resource "aws_s3_bucket_acl" "guide-tfe-es-s3-acl" {
  bucket = aws_s3_bucket.guide-tfe-es-s3.id
  acl    = "private"
}

resource "aws_iam_instance_profile" "guide-tfe-es-inst" {
  name = var.unique_name
  role = aws_iam_role.guide-tfe-es-role.name
}

resource "aws_iam_policy" "bucket_policy" {
  name        = var.unique_name
  path        = "/"
  description = "Allow "

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "VisualEditor0",
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket",
          "s3:DeleteObject"
        ],
        "Resource" : [
          "arn:aws:s3:::${var.bucket_name}/*",
          "arn:aws:s3:::${var.bucket_name}"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "guide-tfe-es-role" {
  name = "guide-tfe-es-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "some_bucket_policy" {
  role       = aws_iam_role.guide-tfe-es-role.name
  policy_arn = aws_iam_policy.bucket_policy.arn
}

locals {
  object_source = "${path.module}/license.rli"
}

resource "aws_s3_object" "file_upload-license" {
  bucket = aws_s3_bucket.guide-tfe-es-s3.id
  key    = "license.rli"
  source = "${path.module}/license.rli"
  # source_hash = filemd5(local.object_source)
}

resource "aws_s3_object" "file_upload-airgapped" {
  bucket = aws_s3_bucket.guide-tfe-es-s3.id
  key    = "TerraformEnterprise.airgap"
  source = "${path.module}/TerraformEnterprise.airgap"
  # source_hash = filemd5(local.object_source)
}

resource "aws_s3_object" "file_upload-replicated" {
  bucket = aws_s3_bucket.guide-tfe-es-s3.id
  key    = "replicated.tar.gz"
  source = "${path.module}/replicated.tar.gz"
  #  source_hash = filemd5(local.object_source)
}