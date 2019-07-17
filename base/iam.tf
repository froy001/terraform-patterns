data "aws_iam_group" "admins" {
  group_name = "Admins"
}

resource "aws_iam_group" "admins" {
  name = "Admins"
  path = "/"
}

resource "aws_iam_group_policy_attachment" "admin_access" {
  group = aws_iam_group.admins.name
  policy_arn = "arn:aws:iam::aws:policy/AdministratorAccess"

}

resource "aws_iam_user" "terraform_main" {
  name = "terraform-main"
  tags = {
    terraform = false
  }
}

resource "aws_iam_user_group_membership" "terraform_main" {
  user = aws_iam_user.terraform_main.name

  groups = [
    data.aws_iam_group.admins.group_name
  ]
}
