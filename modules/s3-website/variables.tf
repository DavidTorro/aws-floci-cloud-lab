variable "bucket_name" {
  description = "Nombre del bucket S3 que aloja la web"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9-]{1,61}[a-z0-9]$", var.bucket_name))
    error_message = "El nombre del bucket solo admite minúsculas, números y guiones (3-63 caracteres)."
  }
}

variable "public_read" {
  description = "Si es true, cualquiera puede leer los objetos de la web"
  type        = bool
  default     = false
}

variable "web_dir" {
  description = "Carpeta con los archivos de la web"
  type        = string

  validation {
    condition     = fileexists("${var.web_dir}/index.html")
    error_message = "La web no tiene portada: falta index.html."
  }

  validation {
    condition     = fileexists("${var.web_dir}/error.html")
    error_message = "La web no tiene página de error: falta error.html."
  }
}
