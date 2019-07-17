resource "aws_organizations_organization" "main" {
  aws_service_access_principals = [
    "cloudtrail.amazonaws.com",
    "config.amazonaws.com",
  ]

  feature_set = "ALL"

  # There is no AWS Organizations API for reading role_name
  # Uncomment if using attribute 'role_name'
  # lifecycle {
  #   ignore_changes = ["role_name"]
  # }
}
