
# Local variables for complex logic
locals {
  # Default nginx configuration for frontend application
  default_nginx_config = jsonencode({ "default.conf" : <<EOF
server {
    listen       80;
    listen  [::]:80;
    server_name  localhost;

    access_log  /var/log/nginx/host.access.log  main;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    # error_page  404              /404.html;

    # redirect server error pages to the static page /50x.html
    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }

    location /saeTest/ {
        proxy_pass  http://${alicloud_slb_load_balancer.slb_load_balancers["backend"].address}:8080/saeTest/; 
    }
}
EOF
  })
}

# VPC resource
resource "alicloud_vpc" "vpc" {
  cidr_block = var.vpc_config.cidr_block
  vpc_name   = var.vpc_config.vpc_name
}

# VSwitch resources using for_each to aggregate multiple switches
resource "alicloud_vswitch" "vswitches" {
  for_each = var.vswitches_config

  vpc_id       = alicloud_vpc.vpc.id
  cidr_block   = each.value.cidr_block
  zone_id      = each.value.zone_id
  vswitch_name = each.value.vswitch_name
}

# Security groups for frontend and backend
resource "alicloud_security_group" "security_groups" {
  for_each = var.security_groups_config

  vpc_id              = alicloud_vpc.vpc.id
  security_group_name = each.value.security_group_name
  description         = each.value.description
}

# SAE namespace
resource "alicloud_sae_namespace" "sae_namespace" {
  namespace_name            = var.sae_namespace_config.namespace_name
  namespace_id              = var.sae_namespace_config.namespace_id
  enable_micro_registration = var.sae_namespace_config.enable_micro_registration
  namespace_description     = var.sae_namespace_config.namespace_description
}

# SAE config map for nginx configuration
resource "alicloud_sae_config_map" "nginx_config_map" {
  namespace_id = alicloud_sae_namespace.sae_namespace.namespace_id
  name         = var.config_map_config.name
  data         = var.custom_nginx_config != null ? var.custom_nginx_config : local.default_nginx_config
  description  = var.config_map_config.description
}

# SAE applications using for_each to handle multiple applications
resource "alicloud_sae_application" "sae_applications" {
  for_each = var.sae_applications_config

  app_name             = each.value.app_name
  namespace_id         = alicloud_sae_namespace.sae_namespace.id
  auto_config          = each.value.auto_config
  vpc_id               = alicloud_vpc.vpc.id
  security_group_id    = alicloud_security_group.security_groups[each.value.security_group_key].id
  vswitch_id           = join(",", [for vswitch_key in each.value.vswitch_keys : alicloud_vswitch.vswitches[vswitch_key].id])
  timezone             = each.value.timezone
  replicas             = each.value.replicas
  cpu                  = each.value.cpu
  memory               = each.value.memory
  package_type         = each.value.package_type
  jdk                  = each.value.jdk
  image_url            = each.value.image_url
  programming_language = each.value.programming_language

  # Dynamic config map mount for frontend application
  dynamic "config_map_mount_desc_v2" {
    for_each = each.value.mount_config_map ? [1] : []
    content {
      config_map_id = alicloud_sae_config_map.nginx_config_map.id
      mount_path    = "/etc/nginx/conf.d/default.conf"
      key           = "default.conf"
    }
  }
}

# SLB load balancers
resource "alicloud_slb_load_balancer" "slb_load_balancers" {
  for_each = var.slb_load_balancers_config

  load_balancer_name = each.value.load_balancer_name
  vswitch_id         = alicloud_vswitch.vswitches[each.value.vswitch_key].id
  load_balancer_spec = each.value.load_balancer_spec
  address_type       = each.value.address_type
}

# SAE load balancer internet attachments
resource "alicloud_sae_load_balancer_internet" "sae_slb_internet" {
  for_each = var.sae_internet_slb_config

  app_id          = alicloud_sae_application.sae_applications[each.value.app_key].id
  internet_slb_id = alicloud_slb_load_balancer.slb_load_balancers[each.value.slb_key].id

  internet {
    protocol    = each.value.protocol
    port        = each.value.port
    target_port = each.value.target_port
  }
}

# SAE load balancer intranet attachments
resource "alicloud_sae_load_balancer_intranet" "sae_slb_intranet" {
  for_each = var.sae_intranet_slb_config

  app_id          = alicloud_sae_application.sae_applications[each.value.app_key].id
  intranet_slb_id = alicloud_slb_load_balancer.slb_load_balancers[each.value.slb_key].id

  intranet {
    protocol    = each.value.protocol
    port        = each.value.port
    target_port = each.value.target_port
  }
}