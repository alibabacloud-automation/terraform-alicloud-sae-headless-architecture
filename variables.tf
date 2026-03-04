variable "vpc_config" {
  type = object({
    cidr_block = string
    vpc_name   = optional(string, "sae-headless-vpc")
  })
  description = "Configuration for VPC. The attribute 'cidr_block' is required."
  default = {
    cidr_block = "192.168.0.0/16"
  }
}

variable "vswitches_config" {
  type = map(object({
    cidr_block   = string
    zone_id      = string
    vswitch_name = optional(string, "sae-headless-vswitch")
  }))
  description = "Configuration for VSwitches. Each VSwitch requires 'cidr_block' and 'zone_id'."
  default     = {}
}

variable "security_groups_config" {
  type = map(object({
    security_group_name = optional(string, "sae-headless-sg")
    description         = optional(string, "Security group for SAE applications")
  }))
  description = "Configuration for security groups."
  default     = {}
}

variable "sae_namespace_config" {
  type = object({
    namespace_name            = optional(string, "sae-headless-ns")
    namespace_id              = string
    enable_micro_registration = optional(bool, false)
    namespace_description     = optional(string, "SAE namespace for headless architecture")
  })
  description = "Configuration for SAE namespace. The attribute 'namespace_id' is required and cannot be changed after creation."
}

variable "config_map_config" {
  type = object({
    name        = optional(string, "nginx")
    description = optional(string, "ConfigMap for nginx configuration")
  })
  description = "Configuration for SAE ConfigMap."
  default     = {}
}

variable "custom_nginx_config" {
  type        = string
  description = "Custom nginx configuration for the frontend application. If not provided, the default configuration will be used."
  default     = null
}

variable "sae_applications_config" {
  type = map(object({
    app_name             = optional(string, "sae-headless-app")
    auto_config          = optional(bool, false)
    security_group_key   = string
    vswitch_keys         = list(string)
    timezone             = optional(string, "Asia/Beijing")
    replicas             = string
    cpu                  = string
    memory               = string
    package_type         = string
    jdk                  = optional(string, null)
    image_url            = string
    programming_language = string
    mount_config_map     = optional(bool, false)
  }))
  description = "Configuration for SAE applications. Required attributes: 'security_group_key', 'vswitch_keys', 'replicas', 'cpu', 'memory', 'package_type', 'image_url', 'programming_language'."
  default     = {}
}

variable "slb_load_balancers_config" {
  type = map(object({
    load_balancer_name = optional(string, "sae-headless-slb")
    vswitch_key        = string
    load_balancer_spec = string
    address_type       = string
  }))
  description = "Configuration for SLB load balancers. Required attributes: 'vswitch_key', 'load_balancer_spec', 'address_type'."
  default     = {}
}

variable "sae_internet_slb_config" {
  type = map(object({
    app_key     = string
    slb_key     = string
    protocol    = string
    port        = number
    target_port = number
  }))
  description = "Configuration for SAE internet SLB attachments. Required attributes: 'app_key', 'slb_key', 'protocol', 'port', 'target_port'."
  default     = {}
}

variable "sae_intranet_slb_config" {
  type = map(object({
    app_key     = string
    slb_key     = string
    protocol    = string
    port        = number
    target_port = number
  }))
  description = "Configuration for SAE intranet SLB attachments. Required attributes: 'app_key', 'slb_key', 'protocol', 'port', 'target_port'."
  default     = {}
}