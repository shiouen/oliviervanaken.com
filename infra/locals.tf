locals {
  domain_name = "oliviervanaken.com"

  ssm_path = "/oliviervanaken.com"

  tags = {
    "project-environment" : "prod"
    "project-source-code" : "https://github.com/shiouen/oliviervanaken.com"
  }
}
