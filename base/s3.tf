
module "tfstate-backend" {
  source  = "https://github.com/froy001/terraform-aws-tfstate-backend.git?ref=develop"
  # insert the 1 required variable here
  region = "${var.region}"
  environment = "${var.env}"
  profile = "${var.aws_profile}"
}
