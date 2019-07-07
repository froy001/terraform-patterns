terraform {
  required_version = ">= 0.12.2"
  backend "s3" {
    bucket         = "tf-infrastructure-devops-state-us-east-2"
    region         = "us-east-2"
    key            = "terraform-infrastructure/state/base/base.tfstate"
    dynamodb_table = "tf-infrastructure-terraformStateLock"
    encrypt        = true
  }
}
