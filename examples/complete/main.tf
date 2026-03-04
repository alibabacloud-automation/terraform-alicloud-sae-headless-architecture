# Data sources for current region
data "alicloud_regions" "current" {
  current = true
}

# Data sources for availability zones
data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

# Random string for unique naming
resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = false
  special = false
}

# Use the SAE headless architecture module
module "sae_headless_architecture" {
  source = "../../"

  # VPC configuration
  vpc_config = {
    cidr_block = "192.168.0.0/16"
    vpc_name   = "vpc-sae-headless-${random_string.suffix.result}"
  }

  # VSwitch configurations
  vswitches_config = {
    "vswitch-1" = {
      cidr_block   = "192.168.1.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "vswitch-1-${random_string.suffix.result}"
    }
    "vswitch-2" = {
      cidr_block   = "192.168.2.0/24"
      zone_id      = data.alicloud_zones.default.zones[0].id
      vswitch_name = "vswitch-2-${random_string.suffix.result}"
    }
    "vswitch-3" = {
      cidr_block   = "192.168.3.0/24"
      zone_id      = data.alicloud_zones.default.zones[1].id
      vswitch_name = "vswitch-3-${random_string.suffix.result}"
    }
    "vswitch-4" = {
      cidr_block   = "192.168.4.0/24"
      zone_id      = data.alicloud_zones.default.zones[1].id
      vswitch_name = "vswitch-4-${random_string.suffix.result}"
    }
  }

  # Security groups configuration
  security_groups_config = {
    "frontend" = {
      security_group_name = "sg-frontend-${random_string.suffix.result}"
      description         = "Security group for frontend applications"
    }
    "backend" = {
      security_group_name = "sg-backend-${random_string.suffix.result}"
      description         = "Security group for backend applications"
    }
  }

  # SAE namespace configuration
  sae_namespace_config = {
    namespace_id              = "${data.alicloud_regions.current.regions[0].id}:${random_string.suffix.result}"
    namespace_name            = "sae-ns-${random_string.suffix.result}"
    enable_micro_registration = false
    namespace_description     = "SAE namespace for headless architecture demo"
  }

  # SAE applications configuration
  sae_applications_config = {
    "backend" = {
      app_name             = "sae-be-${random_string.suffix.result}"
      auto_config          = false
      security_group_key   = "backend"
      vswitch_keys         = ["vswitch-2", "vswitch-4"]
      timezone             = "Asia/Beijing"
      replicas             = "2"
      cpu                  = "500"
      memory               = "2048"
      package_type         = "Image"
      jdk                  = "Dragonwell 21"
      image_url            = "registry.${data.alicloud_regions.current.regions[0].id}.aliyuncs.com/sae-serverless-demo/sae-demo:web-springboot-hellosae-v1.0"
      programming_language = "java"
      mount_config_map     = false
    }
    "frontend" = {
      app_name             = "sae-fe-${random_string.suffix.result}"
      auto_config          = false
      security_group_key   = "frontend"
      vswitch_keys         = ["vswitch-1", "vswitch-3"]
      timezone             = "Asia/Beijing"
      replicas             = "2"
      cpu                  = "500"
      memory               = "2048"
      package_type         = "Image"
      image_url            = "registry.${data.alicloud_regions.current.regions[0].id}.aliyuncs.com/sae-serverless-demo/sae-demo:web-dashboard-hellosae-v1.0"
      programming_language = "other"
      mount_config_map     = true
    }
  }

  # SLB load balancers configuration
  slb_load_balancers_config = {
    "backend" = {
      load_balancer_name = "slb-be-${random_string.suffix.result}"
      vswitch_key        = "vswitch-2"
      load_balancer_spec = "slb.s2.small"
      address_type       = "intranet"
    }
    "frontend" = {
      load_balancer_name = "slb-fe-${random_string.suffix.result}"
      vswitch_key        = "vswitch-1"
      load_balancer_spec = "slb.s2.small"
      address_type       = "internet"
    }
  }

  # SAE internet SLB configuration
  sae_internet_slb_config = {
    "frontend" = {
      app_key     = "frontend"
      slb_key     = "frontend"
      protocol    = "HTTP"
      port        = 80
      target_port = 80
    }
  }

  # SAE intranet SLB configuration
  sae_intranet_slb_config = {
    "backend" = {
      app_key     = "backend"
      slb_key     = "backend"
      protocol    = "HTTP"
      port        = 8080
      target_port = 8080
    }
  }
}