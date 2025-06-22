terraform {
  backend "s3" {
    bucket         = "terraform-buck-luc"
    key            = "my-terraform-environment/main"
    region         = "us-east-2"
    dynamodb_table = "terraform-locks"
  }
}
