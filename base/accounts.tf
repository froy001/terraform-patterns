resource "aws_organizations_account" "master" {
  name  = "master"
  email = "aziz04041975@gmail.com"
}

resource "aws_organizations_account" "identity" {
  name = "identity"
  email = "froy001@gmail.com"
}
