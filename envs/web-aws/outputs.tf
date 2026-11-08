output "bucket" {
  value = module.website.bucket
}

output "website_host" {
  value = module.website.website_endpoint
}

output "check_url" {
  value = "http://${module.website.website_endpoint}/"
}

output "website_url" {
  value = "http://${module.website.website_endpoint}/"
}
