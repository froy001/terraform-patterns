module "tfstate-backend" {
  source  ="git::https://github.com/froy001/terraform-aws-backend-s3.git"
  # insert the 1 required variable here
  # region = "${var.region}"
  backend_dynamodb_lock_table = "${var.dynamodb_lock_table}"
  s3_key = "${var.tf_s3_bucket}"
}
