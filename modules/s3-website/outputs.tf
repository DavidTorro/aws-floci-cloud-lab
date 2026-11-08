output "bucket" {
  value = var.bucket_name
}

output "website_endpoint" {
  value = aws_s3_bucket_website_configuration.this.website_endpoint
}

output "public_read" {
  value = var.public_read
}

output "files" {
  value = sort(keys(aws_s3_object.web))
}
