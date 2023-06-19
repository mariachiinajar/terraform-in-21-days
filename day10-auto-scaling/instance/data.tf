data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "terraform-in-21-days-remote-state"
    key    = "level1-network.tfstate"   # this key must match the name of the state file in your S3 bucket.
    region = "us-east-1"
  }
}

