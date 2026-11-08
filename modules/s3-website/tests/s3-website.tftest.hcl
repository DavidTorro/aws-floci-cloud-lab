mock_provider "aws" {}

variables {
  bucket_name = "nextgen-prueba"
  web_dir     = "../../web"
}

run "web_privada" {
  command = plan

  variables {
    public_read = false
  }

  assert {
    condition     = length(aws_s3_bucket_policy.public_read) == 0
    error_message = "Sin public_read no debe existir política pública."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_policy && aws_s3_bucket_public_access_block.this.restrict_public_buckets
    error_message = "Una web privada debe bloquear las políticas públicas."
  }

  assert {
    condition     = alltrue([for file in ["index.html", "error.html", "estilos.css"] : contains(keys(aws_s3_object.web), file)])
    error_message = "Deben subirse la portada, la página de error y los estilos."
  }

  assert {
    condition     = aws_s3_object.web["index.html"].content_type == "text/html; charset=utf-8" && aws_s3_object.web["estilos.css"].content_type == "text/css; charset=utf-8"
    error_message = "Cada archivo debe subirse con su tipo de contenido."
  }

  assert {
    condition     = aws_s3_bucket_website_configuration.this.index_document[0].suffix == "index.html" && aws_s3_bucket_website_configuration.this.error_document[0].key == "error.html"
    error_message = "El modo sitio web debe usar index.html y error.html."
  }
}

run "web_publica" {
  command = plan

  variables {
    public_read = true
  }

  assert {
    condition     = length(aws_s3_bucket_policy.public_read) == 1
    error_message = "Con public_read debe crearse la política de lectura pública."
  }

  assert {
    condition     = !aws_s3_bucket_public_access_block.this.block_public_policy && !aws_s3_bucket_public_access_block.this.restrict_public_buckets
    error_message = "Una web pública debe permitir la política pública."
  }

  assert {
    condition     = aws_s3_bucket_public_access_block.this.block_public_acls && aws_s3_bucket_public_access_block.this.ignore_public_acls
    error_message = "Las ACL públicas deben seguir bloqueadas."
  }
}

run "web_sin_portada" {
  command = plan

  variables {
    web_dir = "tests/sin-portada"
  }

  expect_failures = [var.web_dir]
}

run "nombre_de_bucket_invalido" {
  command = plan

  variables {
    bucket_name = "NextGen_Web"
  }

  expect_failures = [var.bucket_name]
}
