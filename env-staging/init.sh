#!/bin/bash

# Usage: ./init.sh once to initialize remote storage for this environment.
# Subsequent tf actions in this environment don't require re-initialization,
# unless you have completely cleared your .terraform cache.
#
# terraform plan  -var-file=./production.tfvars
# terraform apply -var-file=./production.tfvars
#
# Make sure you populate the repo's .env file in the root of the repo
source ../.env


if [ -z "$(which terraform 2>/dev/null)" ]; then
  echo "unable to find 'terraform' in \$PATH, exiting."
  exit 1
fi

if [ -z ${TF_PROJECT_NAME} ]; then
  echo "'TF_PROJECT_NAME' is empty, exiting with failure."
  exit 1
fi

set -e

tf_spine="${TF_SPINE:-rk}"
tf_env="staging"

aws_default_region="${AWS_DEFAULT_REGION:-us-east-1}"

s3_bucket="${tf_spine}-devops-state-${aws_default_region}"
s3_prefix="${TF_PROJECT_NAME}/state/${tf_env}"

tf_version="${TF_VERSION:-0.12.2}"
tf_lock_table="${TF_LOCK_TABLE:-rk-terraformStateLock}"

FILE="terraform.tf"
S3_FILE="s3.tf"

function create_backend_bucket {
    set -e
    local plan_out_file="${tf_env}_plan"
    cat > "${S3_FILE}" <<EOF

module "tfstate-backend" {
    source  = "git::https://github.com/froy001/terraform-aws-tfstate-backend.git?ref=develop"
    # insert the 1 required variable here
    region = "${aws_default_region}"
    s3_bucket_name = "${s3_bucket}"
    dynamodb_lock_table = "${tf_lock_table}"
    environment = "\${var.env}"
    profile = "\${var.aws_profile}"
    tags = { owner = "terraform" }
}
EOF

    echo "\nPopulating $S3_FILE for main state bucket"

    terraform fmt -list=false $S3_FILE
    echo -e "\n...\nInitialize terraform for bucket creation"
    terraform init
    terraform plan -out "${plan_out_file}"
    echo -e "\e[33m\nIf everything seems ok run \e[32mterrform apply $plan_out_file\e[33m to apply the state bucket"
    echo -e "\e[33mAfter that please run the init.sh file again to initialize the remote state"
}
if [ $tf_env = "base" ]; then
    if [ ! -s $S3_FILE ]; then
        create_backend_bucket
        exit 1
    else
        echo -e "\e[33mIf you are running this script for the first time you must delete \e[34ms3.tf"
        echo -e "\e[33mAnd re-run ]\e[34minit.sh"
    fi
fi

export TF=$(cat <<EOF
terraform {
  required_version = ">= ${tf_version}"
  backend "s3" {
    bucket = "${s3_bucket}"
    region = "${aws_default_region}"
    key    = "${s3_prefix}/${tf_env}.tfstate"
    dynamodb_table = "${tf_lock_table}"
    encrypt = true
  }
}
EOF
)

if [ ! -s $FILE ]; then
  echo "Populating terraform.tf for this environment"
  echo "$TF" > $FILE
  terraform fmt -list=false $FILE
fi

terraform init -backend=true \
               -backend-config="bucket=${s3_bucket}" \
               -backend-config="key=${s3_prefix}/${tf_env}.tfstate" \
               -backend-config="region=${aws_default_region}"

echo "set remote s3 state to ${s3_bucket}/${s3_prefix}/${tf_env}.tfstate"
# vim: set et fenc=utf-8 ff=unix sts=2 sw=2 ts=2 :
