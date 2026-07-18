variable "location" {
  description = "Azure region for resource deployment"
  type        = string
  default     = "Australia East"
}

# -----------------------------------------------------------------------------
# MySQL (GLPI database server)
# -----------------------------------------------------------------------------

variable "mysql_admin_username" {
  description = "Admin username for the Azure MySQL server"
  type        = string
  default     = "mysqladmin"
}

variable "mysql_admin_password" {
  description = "Admin password for the Azure MySQL server"
  type        = string
  sensitive   = true
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

# -----------------------------------------------------------------------------
# GLPI application
# -----------------------------------------------------------------------------

variable "glpi_version" {
  description = "GLPI version / build to deploy"
  type        = string
  default     = "11.0.8"
}

variable "glpi_http_port" {
  description = "HTTP port exposed by the GLPI container/service"
  type        = string
  default     = "80"
}

variable "glpi_server_name" {
  description = "Server/domain name (FQDN) for the GLPI instance, used by Apache"
  type        = string
  default     = "localhost" #"glpi.lucidbyte.com.au"
}

variable "php_timezone" {
  description = "PHP timezone setting for the GLPI container"
  type        = string
  default     = "Australia/Melbourne"
}

variable "apache_log_dir" {
  description = "Directory path for Apache logs inside the GLPI container"
  type        = string
  default     = "/var/log/glpi/apache2"
}
# -----------------------------------------------------------------------------
# GLPI database connection
# -----------------------------------------------------------------------------

variable "glpi_db_port" {
  description = "The port for the GLPI MySQL database"
  type        = string
  default     = "3306"
}

variable "glpi_db_name" {
  description = "The database name for GLPI"
  type        = string
  default     = "glpi"
}

# -----------------------------------------------------------------------------
# Dolibarr application
# -----------------------------------------------------------------------------

variable "dolibarr_version" {
  description = "Dolibarr version / build to deploy"
  type        = string
  default     = "23.0.3"
}

variable "dolibarr_http_port" {
  description = "HTTP port exposed by the Dolibarr container/service"
  type        = string
  default     = "80"
}

variable "dolibarr_url_root" {
  description = "Public URL root for the Dolibarr instance (DOLI_URL_ROOT), used to build conf.php"
  type        = string
  default     = "http://localhost"
}

variable "dolibarr_force_https" {
  description = "Whether Dolibarr should force HTTPS (DOLI_FORCE_HTTPS: '0' or '1')"
  type        = string
  default     = "0"
}

variable "dolibarr_prod" {
  description = "Whether Dolibarr should run in production mode (DOLI_PROD: '0' or '1')"
  type        = string
  default     = "1"
}

# -----------------------------------------------------------------------------
# Dolibarr database connection
# -----------------------------------------------------------------------------

variable "dolibarr_db_port" {
  description = "The port for the Dolibarr PostgreSQL database"
  type        = string
  default     = "5432"
}

variable "dolibarr_pg_sslmode" {
  description = "libpq SSL mode for the Dolibarr connection to Azure PostgreSQL (DOLI_PG_SSLMODE)"
  type        = string
  default     = "disable"
}

# -----------------------------------------------------------------------------
# n8n application
# -----------------------------------------------------------------------------

variable "n8n_version" {
  description = "n8n version / build to deploy"
  type        = string
  default     = "2.28.6"
}

variable "n8n_runners_auth_token" {
  description = "Shared secret used to authenticate the runner sidecar to the n8n broker"
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# Zabbix application
# -----------------------------------------------------------------------------


variable "zabbix_image_tag" {
  description = "Tag used for the zabbix-server-pgsql and zabbix-web-nginx-pgsql images pushed to ACR (matches the compose file's 'trunk-alpine')."
  type        = string
  default     = "trunk-alpine"
}

variable "zabbix_db_name" {
  description = "Name of the PostgreSQL database created for Zabbix."
  type        = string
  default     = "zabbix"
}

variable "db_server_port" {
  description = "PostgreSQL port Zabbix connects to (DB_SERVER_PORT)."
  type        = number
  default     = 5432
}

variable "zbx_startpollers" {
  description = "Number of Zabbix poller processes to start (ZBX_STARTPOLLERS)."
  type        = number
  default     = 5
}

variable "zbx_startpollersunreachable" {
  description = "Number of Zabbix unreachable-poller processes to start (ZBX_STARTPOLLERSUNREACHABLE)."
  type        = number
  default     = 1
}

variable "zbx_starttrappers" {
  description = "Number of Zabbix trapper processes to start (ZBX_STARTTRAPPERS)."
  type        = number
  default     = 5
}

variable "zbx_cachesize" {
  description = "Size of the Zabbix configuration cache (ZBX_CACHESIZE), e.g. '8M'."
  type        = string
  default     = "64M"
}


# -----------------------------------------------------------------------------
# Velociraptor application
# -----------------------------------------------------------------------------

variable "velociraptor_version" {
  description = "Velociraptor release version to build/pull, e.g. 0.74.5 (matches VELOCIRAPTOR_VERSION in the Dockerfile/compose file)."
  type        = string
  default     = "0.77.1"
}

variable "velociraptor_frontend_hostname" {
  description = "Public hostname clients use to reach the Velociraptor frontend (port 8000). Should resolve to this Container App's FQDN."
  type        = string
  default = "localhost"
}

variable "velociraptor_bind_address" {
  description = "Bind address for the Velociraptor Frontend/API/GUI/Monitoring listeners inside the container."
  type        = string
  default     = "0.0.0.0"
}

variable "velociraptor_admin_username" {
  description = "Initial Velociraptor admin username, created on first boot when no config exists yet."
  type        = string
  default     = "admin"
}

variable "velociraptor_admin_password" {
  description = "Initial Velociraptor admin password, created on first boot when no config exists yet."
  type        = string
  sensitive   = true
}

# -----------------------------------------------------------------------------
# MeshCentral application
# -----------------------------------------------------------------------------

variable "mesh_version" {
  description = "MeshCentral npm package version to build/deploy (e.g. \"1.1.35\" or \"latest\")"
  type        = string
  default     = "1.2.1"
}

variable "mesh_hostname" {
  description = "Public hostname used for MeshCentral's TLS cert and agent connect-back URL. Leave empty to default to the Container App Environment's default domain."
  type        = string
  default     = ""
}

variable "meshcentral_db_port" {
  description = "Postgres port MeshCentral connects to"
  type        = string
  default     = "5432"
}

# -----------------------------------------------------------------------------
# Semaphore application
# -----------------------------------------------------------------------------


variable "semaphore_version" {
  description = "Image tag to deploy, matching the SEMAPHORE_VERSION build arg / tag pushed to ACR"
  type        = string
  default     = "v2.18.25"
}

variable "semaphore_db_port" {
  description = "Postgres port Semaphore connects to (SEMAPHORE_DB_PORT)"
  type        = string
  default     = "5432"
}

variable "semaphore_admin" {
  description = "Semaphore admin username (SEMAPHORE_ADMIN)"
  type        = string
  default     = "semaphore_admin"
}

variable "semaphore_admin_password" {
  description = "Semaphore admin password (SEMAPHORE_ADMIN_PASSWORD)"
  type        = string
  sensitive   = true
}

variable "semaphore_admin_name" {
  description = "Display name for the Semaphore admin user (SEMAPHORE_ADMIN_NAME)"
  type        = string
  default     = "admin"
}

variable "semaphore_access_key_encryption" {
  description = "Base64 key used to encrypt stored credentials/secrets (SEMAPHORE_ACCESS_KEY_ENCRYPTION)"
  type        = string
  sensitive   = true
}

variable "semaphore_playbook_path" {
  description = "Path inside the container where playbooks are mounted (SEMAPHORE_PLAYBOOK_PATH)"
  type        = string
  default     = "/tmp/semaphore/"
}
