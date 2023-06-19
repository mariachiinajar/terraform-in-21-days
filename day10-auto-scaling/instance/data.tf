data "terraform_remote_state" "network" {
  backend = "s3"

  config = {
    bucket = "terraform-in-21-days-remote-state"
    key    = "network.tfstate"
    region = "us-east-1"
  }
}

