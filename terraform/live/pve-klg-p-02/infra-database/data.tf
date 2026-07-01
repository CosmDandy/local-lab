data "terraform_remote_state" "bootstrap" {
  backend = "remote"
  config = {
    hostname     = "app.terraform.io"
    organization = "CosmDandy"
    workspaces = {
      name = "kvt-lab-infra-bootstrap"
    }
  }
}
