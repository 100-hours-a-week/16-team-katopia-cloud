terraform {
  backend "s3" {
    bucket         = "katopia-terraform-remote-state-prod"
    key            = "envs/docker/terraform.tfstate"
    region         = "ap-northeast-2"
    dynamodb_table = "katopia-terraform-remote-state-prod-lock"
    encrypt        = true
  }
}
