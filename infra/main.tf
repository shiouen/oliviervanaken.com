provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = local.tags
  }
}

provider "aws" {
  alias  = "us-east-1"
  region = "us-east-1"

  default_tags {
    tags = local.tags
  }
}

terraform {
  backend "gcs" {
    bucket = "rt-terraform-backends"
    prefix = "oliviervaken.com"
  }
}
