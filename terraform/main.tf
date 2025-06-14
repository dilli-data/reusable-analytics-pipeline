terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = "~> 0.87"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

provider "snowflake" {
  account  = var.snowflake_account
  username = var.snowflake_username
  password = var.snowflake_password
  region   = var.snowflake_region
}

# S3 bucket for raw data
resource "aws_s3_bucket" "education_data_lake" {
  bucket = "education-data-lake-${var.environment}"

  tags = {
    Name        = "Education Data Lake"
    Environment = var.environment
  }
}

# S3 bucket for processed data
resource "aws_s3_bucket" "processed_data" {
  bucket = "processed-education-data-${var.environment}"

  tags = {
    Name        = "Processed Education Data"
    Environment = var.environment
  }
}

# AWS Glue job for data processing
resource "aws_glue_job" "process_sis_data" {
  name     = "process-sis-data-${var.environment}"
  role_arn = aws_iam_role.glue_role.arn

  command {
    script_location = "s3://${aws_s3_bucket.education_data_lake.bucket}/scripts/process_sis_data.py"
  }

  default_arguments = {
    "--job-language" = "python"
    "--job-bookmark-option" = "job-bookmark-enable"
  }
}

# Snowflake resources
resource "snowflake_database" "education_analytics" {
  name    = "EDUCATION_ANALYTICS_${upper(var.environment)}"
  comment = "Database for education analytics pipeline"
}

resource "snowflake_schema" "raw" {
  database = snowflake_database.education_analytics.name
  name     = "RAW"
  comment  = "Raw data schema"
}

resource "snowflake_schema" "staging" {
  database = snowflake_database.education_analytics.name
  name     = "STAGING"
  comment  = "Staging data schema"
}

resource "snowflake_schema" "analytics" {
  database = snowflake_database.education_analytics.name
  name     = "ANALYTICS"
  comment  = "Analytics schema"
}

# IAM role for Glue
resource "aws_iam_role" "glue_role" {
  name = "glue-education-analytics-${var.environment}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
}

# IAM policy for Glue
resource "aws_iam_role_policy" "glue_policy" {
  name = "glue-education-analytics-policy-${var.environment}"
  role = aws_iam_role.glue_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          aws_s3_bucket.education_data_lake.arn,
          "${aws_s3_bucket.education_data_lake.arn}/*",
          aws_s3_bucket.processed_data.arn,
          "${aws_s3_bucket.processed_data.arn}/*"
        ]
      }
    ]
  })
} 