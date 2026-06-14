terraform {
  backend "s3" {
    bucket = "eks-bucket-projectjan"
    key    = "terraform.tfstate"
    region = "us-east-1"

        use_lockfile = true
        encrypt        = true
  
  }
}