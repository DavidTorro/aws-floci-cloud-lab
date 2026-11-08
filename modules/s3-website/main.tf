locals {
  content_types = {
    html = "text/html; charset=utf-8"
    css  = "text/css; charset=utf-8"
    js   = "application/javascript"
    json = "application/json"
    svg  = "image/svg+xml"
    png  = "image/png"
    jpg  = "image/jpeg"
    ico  = "image/x-icon"
  }

  files = fileset(var.web_dir, "**")
}

# El bucket lo crea scripts/web-deploy.sh con la AWS CLI: en Learner Lab una SCP
# deniega s3:GetBucketObjectLockConfiguration, una lectura que el recurso
# aws_s3_bucket hace siempre y que no se puede desactivar. Este módulo gestiona
# todo lo que va dentro del bucket.
resource "aws_s3_bucket_website_configuration" "this" {
  bucket = var.bucket_name

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "error.html"
  }
}

# Privado por defecto: solo se abre la puerta a políticas públicas si se pide.
resource "aws_s3_bucket_public_access_block" "this" {
  bucket = var.bucket_name

  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = !var.public_read
  restrict_public_buckets = !var.public_read
}

resource "aws_s3_bucket_policy" "public_read" {
  count = var.public_read ? 1 : 0

  bucket = var.bucket_name
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Sid       = "LecturaPublica"
      Effect    = "Allow"
      Principal = "*"
      Action    = "s3:GetObject"
      Resource  = "arn:aws:s3:::${var.bucket_name}/*"
    }]
  })

  depends_on = [aws_s3_bucket_public_access_block.this]
}

# Cada archivo de la web es un objeto; si se borra un archivo, se borra su objeto.
resource "aws_s3_object" "web" {
  for_each = local.files

  bucket       = var.bucket_name
  key          = each.value
  source       = "${var.web_dir}/${each.value}"
  etag         = filemd5("${var.web_dir}/${each.value}")
  content_type = lookup(local.content_types, lower(regex("[^.]*$", each.value)), "application/octet-stream")
}
