provider "aws" {
    region = var.region
}

#resource "aws_s3_bucket" "tf_state_backend_bucket" {
#    bucket = "purestorage-tf-backend-state-${random_string.bucket_suffix.result}" 
#    acl = "private"
#
#    lifecycle {
#        prevent_destroy = false
#    }
#
#    versioning {
#        enabled = true
#    }
#
#    server_side_encryption_configuration {
#        rule {
#            apply_server_side_encryption_by_default {
#                sse_algorithm = "AES256"
#            }
#        }
#    }
#    
#    tags = {
#        Name = "purestorage Demo tf state bucket"
#        Environment = "dev"
#    }
#}

#resource "aws_dynamodb_table" "tf_state_backend_locks" {
#    name = "terraform-state-locks"
#    billing_mode = "PAY_PER_REQUEST"
#    hash_key = "LockID"
#
#    attribute {
#        name = "LockID"
#        type = "S"
#    }
#}

# terraform {
#     backend "s3" {
#         bucket = aws_s3_bucket.tf_state_backend_bucket.bucket
#         key = "global/s3/terraform.tfstate"
#         region = var.region
#         dynamodb_table = "terraform-state-locks"
#         encrypt = true
#     }
# }

resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  lower = true
  upper = false
  number = false
}
