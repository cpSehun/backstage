terraform {
  required_version = ">= 1.0"

  backend "s3" {
    # 위에서 생성한 S3 버킷 이름으로 변경하세요
    bucket = "cplabs-backstage-terraform-state-20250731" # 여기를 변경
    key    = "backstage/terraform.tfstate"
    region = "ap-northeast-2"
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31.0"
    }
  }
}

provider "aws" {
  region  = var.aws_region
  profile = "cp9"
}
