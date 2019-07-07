variable "dynamodb_lock_table" {
  description = "The name of the dynamodb lock table for the env"
  type = "string"
  default = "tf-infrastructure-terraformLockTable"
}
