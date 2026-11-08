# El estado vive en un bucket S3 de la cuenta para que GitHub Actions, que
# arranca cada vez en un equipo limpio, sepa qué recursos existen ya.
# El nombre del bucket lo pasa scripts/web-deploy.sh con -backend-config.
terraform {
  backend "s3" {
    key          = "web-nextgen/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }
}
