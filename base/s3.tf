module "tfstate-backend" {
  source = "git::https://github.com/froy001/terraform-aws-tfstate-backend.git?ref=develop"
  # insert the 1 required variable here
  region              = "us-east-2"
  s3_bucket_name      = "tf-infrastructure-devops-state-us-east-2"
  dynamodb_lock_table = "tf-infrastructure-terraformStateLock"
  environment         = "${var.env}"
  profile             = "${var.aws_profile}"
  tags                = { owner = "terraform" }
}
