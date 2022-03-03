terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.66.0"
    }
    github = {
      source  = "integrations/github"
      version = ">=4.5.1"
    }
  }
}

locals {
  app_port = "3000"
}

resource "azurerm_resource_group" "web_ui" {
  name     = "${var.name}-rg"
  location = var.location
}

resource "azurerm_container_group" "web_ui" {
  name                = "web-ui"
  location            = azurerm_resource_group.web_ui.location
  resource_group_name = azurerm_resource_group.web_ui.name
  dns_name_label      = var.name
  ip_address_type     = "Public"
  os_type             = "Linux"

  image_registry_credential {
    server   = var.ui_container_registry
    username = var.ui_container_registry_user
    password = var.ui_container_registry_password
  }

  container {
    name   = "web-ui"
    image  = "${var.ui_container_registry}/${var.ui_container_image}:${var.ui_container_image_tag}"
    cpu    = "0.5"
    memory = "1.5"

    ports {
      port     = local.app_port
      protocol = "TCP"
    }

    environment_variables = {
      BLOB_STORAGE_ACCOUNT    = var.blob_store_account
      BLOB_STORAGE_CONTAINER  = var.blob_store
      CONTROL_REPO_EVENT_TYPE = "run-simulation"
      CONTROL_REPO_NWO        = var.control_repo
      DB_DATABASE             = var.db
      DB_HOST                 = var.db_host
      DB_USERNAME             = var.db_username
      GITHUB_CLIENT_ID        = var.github_client_id
      RUNNER_CALLBACK_URL     = "https://${var.proxy_url}"
    }
    secure_environment_variables = {
      BLOB_STORAGE_KEY     = var.blob_store_key
      DB_PASSWORD          = var.db_password
      GITHUB_API_TOKEN     = var.github_api_pat
      GITHUB_CLIENT_SECRET = var.github_client_secret
      OAUTH_SECRET         = var.oauth_secret
      RUNNER_SHARED_SECRET = var.runner_shared_secret
      SESSION_SECRET       = var.session_secret
    }
  }

  container {
    name   = "nginx-with-ssl"
    image  = "nginx:1.18"
    cpu    = "0.5"
    memory = "1.5"
    ports {
      port     = 80
      protocol = "TCP"
    }
    ports {
      port     = 443
      protocol = "TCP"
    }
    volume {
      name       = "nginx-config"
      mount_path = "/etc/nginx"
      secret = {
        "ssl.crt"    = base64encode(var.ssl_crt)
        "ssl.key"    = base64encode(var.ssl_key)
        "nginx.conf" = base64encode(data.template_file.nginx_conf.rendered)
      }
    }
    dynamic "volume" {
      for_each = var.letsencrypt_challenge_name != "" ? ["__dummy__"] : []
      content {
        name       = "letsencrypt"
        mount_path = "/var/www/letsencrypt/.well-known/acme-challenge/"
        secret = {
          (var.letsencrypt_challenge_name) = base64encode(var.letsencrypt_challenge_value)
        }
      }
    }
  }
}

data "template_file" "nginx_conf" {
  template = file("${path.module}/nginx.conf.tpl")
  vars = {
    server_name = var.proxy_url
    app_port    = local.app_port
  }
}
