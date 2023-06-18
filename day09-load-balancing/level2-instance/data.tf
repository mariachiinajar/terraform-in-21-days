data "terraform_remote_state" "level1-network" {
  backend = "s3"

  config = {
    bucket = "terraform-in-21-days-remote-state"
    key    = "level1-network.tfstate"
    region = "us-east-1"
  }
}

