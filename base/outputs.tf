output "main_org_id" {
  value = "${aws_organizations_organization.main.id}"
}

output "identity_account_id" {
  value = aws_organizations_account.identity.id
}

output "identity_account_arn" {
  value = aws_organizations_account.identity.arn
}
