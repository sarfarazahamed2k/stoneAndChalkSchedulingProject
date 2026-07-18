resource "azurerm_postgresql_flexible_server" "postgres" {
  name                   = "stone-and-chalk-webapp-schedule"
  resource_group_name    = azurerm_resource_group.rg.name
  location               = azurerm_resource_group.rg.location
  administrator_login    = var.postgres_admin_username
  administrator_password = var.postgres_admin_password
  sku_name               = "B_Standard_B1ms"
  version                = "18"
  backup_retention_days  = 7
  zone                   = "1"

  storage_mb        = 32768
  storage_tier      = "P4"
  auto_grow_enabled = true

  public_network_access_enabled = true

#   lifecycle {
#     prevent_destroy = true
#   }
}

# Allow connections from any IP address
resource "azurerm_postgresql_flexible_server_firewall_rule" "allow_all" {
  name             = "allow-all"
  server_id        = azurerm_postgresql_flexible_server.postgres.id
  start_ip_address = "0.0.0.0"
  end_ip_address   = "255.255.255.255"
}

resource "azurerm_postgresql_flexible_server_configuration" "require_secure_transport" {
  name      = "require_secure_transport"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  value     = "OFF"
}

resource "azurerm_postgresql_flexible_server_database" "webapp_db" {
  name      = "webapp"
  server_id = azurerm_postgresql_flexible_server.postgres.id
  charset   = "UTF8"
  collation = "en_US.utf8"
}

output "postgres_fqdn" {
  value = azurerm_postgresql_flexible_server.postgres.fqdn
}

resource "terraform_data" "db_init" {
  depends_on = [
    azurerm_postgresql_flexible_server_database.webapp_db,
    azurerm_postgresql_flexible_server_firewall_rule.allow_all
  ]

  # re-run when the SQL file changes
  triggers_replace = filesha256("${path.module}/schema.sql")

  provisioner "local-exec" {
    command = "psql -h ${azurerm_postgresql_flexible_server.postgres.fqdn} -p 5432 -d webapp -U ${var.postgres_admin_username} -f ${path.module}/schema.sql"
    environment = {
      PGPASSWORD  = var.postgres_admin_password
      PGSSLMODE   = "require"
    }
  }
}