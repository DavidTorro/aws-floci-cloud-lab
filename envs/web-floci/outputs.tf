output "bucket" {
  value = module.website.bucket
}

# Floci sirve la web en el puerto 4566 y la distingue por el nombre de host.
output "website_host" {
  value = "${module.website.bucket}.s3-website-us-east-1.localhost:4566"
}

output "check_url" {
  value = "http://localhost:4566/"
}

output "website_url" {
  value = "http://${module.website.bucket}.s3-website-us-east-1.localhost:4566/"
}
