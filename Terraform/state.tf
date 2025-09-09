# state.tf
terraform {
  backend "s3" {
    endpoint   = ""
    bucket = "" 
    key    = ""
    region = ""
    profile= ""

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}