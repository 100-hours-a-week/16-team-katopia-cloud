terraform {
  backend "s3" {
    bucket         = "katopia-terraform-remote-state-dev"
    key            = "envs/dev/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "katopia-terraform-remote-state-dev-lock"
    encrypt        = true
  }
}
