# Los valores se leen de config/web.tfvars, compartido por Floci y AWS.
variable "bucket_name" {
  description = "Nombre del bucket S3 que aloja la web"
  type        = string
}

variable "public_read" {
  description = "Si es true, cualquiera puede leer la web"
  type        = bool
}
