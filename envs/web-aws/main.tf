module "website" {
  source = "../../modules/s3-website"

  bucket_name = var.bucket_name
  public_read = var.public_read
  web_dir     = "${path.root}/../../web"
}
