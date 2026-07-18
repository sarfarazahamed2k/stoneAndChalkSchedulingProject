variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "Australia East"
}

# -----------------------------------------------------------------------------
# PostgreSQL
# -----------------------------------------------------------------------------

variable "postgres_admin_username" {
  description = "Admin username for the Azure PostgreSQL server"
  type        = string
  default     = "postgresadmin"
}

variable "postgres_admin_password" {
  description = "Admin password for the Azure PostgreSQL server"
  type        = string
  sensitive   = true
}