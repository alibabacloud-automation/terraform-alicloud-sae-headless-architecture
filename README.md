Alibaba Cloud SAE Headless Architecture Terraform Module

# terraform-alicloud-sae-headless-architecture

English | [简体中文](https://github.com/alibabacloud-automation/terraform-alicloud-sae-headless-architecture/blob/main/README-CN.md)

Terraform module which creates a complete headless architecture solution using Alibaba Cloud Serverless App Engine (SAE). This module implements the [The Headless Architecture Solution of Alibaba Cloud (SAE)](https://www.aliyun.com/solution/tech-solution-deploy/2866912) to enable frontend-backend separation architecture with SAE applications, load balancers, and supporting infrastructure. The solution provides a scalable, serverless approach to building modern web applications with separated frontend and backend services.

## Usage

This module creates a complete SAE-based headless architecture including VPC, VSwitches, security groups, SAE namespace, applications, and load balancers. It's designed for scenarios where you need to deploy frontend and backend applications with proper separation and load balancing.

```terraform
data "alicloud_regions" "current" {
  current = true
}

data "alicloud_zones" "default" {
  available_resource_creation = "VSwitch"
}

resource "random_string" "suffix" {
  length  = 8
  lower   = true
  upper   = false
  numeric = false
  special = false
}

module "sae_headless_architecture" {
  source = "alibabacloud-automation/sae-headless-architecture/alicloud"

  # VPC configuration
  vpc_config = {
    cidr_block = "192.168.0.0/16"
  }

  # VSwitch configurations
  vswitches_config = {
    "vswitch-1" = {
      cidr_block = "192.168.1.0/24"
      zone_id    = data.alicloud_zones.default.zones[0].id
    }
    "vswitch-2" = {
      cidr_block = "192.168.2.0/24"
      zone_id    = data.alicloud_zones.default.zones[0].id
    }
  }

  # Security groups configuration
  security_groups_config = {
    "frontend" = {
      description = "Security group for frontend applications"
    }
    "backend" = {
      description = "Security group for backend applications"
    }
  }

  # SAE namespace configuration
  sae_namespace_config = {
    namespace_id              = "${data.alicloud_regions.current.regions[0].id}:${random_string.suffix.result}"
    enable_micro_registration = false
  }

  # SAE applications configuration
  sae_applications_config = {
    "backend" = {
      security_group_key   = "backend"
      vswitch_keys         = ["vswitch-2"]
      replicas             = "2"
      cpu                  = "500"
      memory               = "2048"
      package_type         = "Image"
      image_url            = "registry.${data.alicloud_regions.current.regions[0].id}.aliyuncs.com/sae-serverless-demo/sae-demo:web-springboot-hellosae-v1.0"
      programming_language = "java"
    }
    "frontend" = {
      security_group_key   = "frontend"
      vswitch_keys         = ["vswitch-1"]
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
      vswitch_key        = "vswitch-2"
      load_balancer_spec = "slb.s2.small"
      address_type       = "intranet"
    }
    "frontend" = {
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
```

## Examples

* [Complete Example](https://github.com/alibabacloud-automation/terraform-alicloud-sae-headless-architecture/tree/main/examples/complete)

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_alicloud"></a> [alicloud](#provider\_alicloud) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [alicloud_sae_application.sae_applications](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/sae_application) | resource |
| [alicloud_sae_config_map.nginx_config_map](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/sae_config_map) | resource |
| [alicloud_sae_load_balancer_internet.sae_slb_internet](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/sae_load_balancer_internet) | resource |
| [alicloud_sae_load_balancer_intranet.sae_slb_intranet](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/sae_load_balancer_intranet) | resource |
| [alicloud_sae_namespace.sae_namespace](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/sae_namespace) | resource |
| [alicloud_security_group.security_groups](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/security_group) | resource |
| [alicloud_slb_load_balancer.slb_load_balancers](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/slb_load_balancer) | resource |
| [alicloud_vpc.vpc](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vpc) | resource |
| [alicloud_vswitch.vswitches](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs/resources/vswitch) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_config_map_config"></a> [config\_map\_config](#input\_config\_map\_config) | Configuration for SAE ConfigMap. | <pre>object({<br/>    name        = optional(string, "nginx")<br/>    description = optional(string, "ConfigMap for nginx configuration")<br/>  })</pre> | `{}` | no |
| <a name="input_custom_nginx_config"></a> [custom\_nginx\_config](#input\_custom\_nginx\_config) | Custom nginx configuration for the frontend application. If not provided, the default configuration will be used. | `string` | `null` | no |
| <a name="input_sae_applications_config"></a> [sae\_applications\_config](#input\_sae\_applications\_config) | Configuration for SAE applications. Required attributes: 'security\_group\_key', 'vswitch\_keys', 'replicas', 'cpu', 'memory', 'package\_type', 'image\_url', 'programming\_language'. | <pre>map(object({<br/>    app_name             = optional(string, "sae-headless-app")<br/>    auto_config          = optional(bool, false)<br/>    security_group_key   = string<br/>    vswitch_keys         = list(string)<br/>    timezone             = optional(string, "Asia/Beijing")<br/>    replicas             = string<br/>    cpu                  = string<br/>    memory               = string<br/>    package_type         = string<br/>    jdk                  = optional(string, null)<br/>    image_url            = string<br/>    programming_language = string<br/>    mount_config_map     = optional(bool, false)<br/>  }))</pre> | `{}` | no |
| <a name="input_sae_internet_slb_config"></a> [sae\_internet\_slb\_config](#input\_sae\_internet\_slb\_config) | Configuration for SAE internet SLB attachments. Required attributes: 'app\_key', 'slb\_key', 'protocol', 'port', 'target\_port'. | <pre>map(object({<br/>    app_key     = string<br/>    slb_key     = string<br/>    protocol    = string<br/>    port        = number<br/>    target_port = number<br/>  }))</pre> | `{}` | no |
| <a name="input_sae_intranet_slb_config"></a> [sae\_intranet\_slb\_config](#input\_sae\_intranet\_slb\_config) | Configuration for SAE intranet SLB attachments. Required attributes: 'app\_key', 'slb\_key', 'protocol', 'port', 'target\_port'. | <pre>map(object({<br/>    app_key     = string<br/>    slb_key     = string<br/>    protocol    = string<br/>    port        = number<br/>    target_port = number<br/>  }))</pre> | `{}` | no |
| <a name="input_sae_namespace_config"></a> [sae\_namespace\_config](#input\_sae\_namespace\_config) | Configuration for SAE namespace. The attribute 'namespace\_id' is required and cannot be changed after creation. | <pre>object({<br/>    namespace_name            = optional(string, "sae-headless-ns")<br/>    namespace_id              = string<br/>    enable_micro_registration = optional(bool, false)<br/>    namespace_description     = optional(string, "SAE namespace for headless architecture")<br/>  })</pre> | n/a | yes |
| <a name="input_security_groups_config"></a> [security\_groups\_config](#input\_security\_groups\_config) | Configuration for security groups. | <pre>map(object({<br/>    security_group_name = optional(string, "sae-headless-sg")<br/>    description         = optional(string, "Security group for SAE applications")<br/>  }))</pre> | `{}` | no |
| <a name="input_slb_load_balancers_config"></a> [slb\_load\_balancers\_config](#input\_slb\_load\_balancers\_config) | Configuration for SLB load balancers. Required attributes: 'vswitch\_key', 'load\_balancer\_spec', 'address\_type'. | <pre>map(object({<br/>    load_balancer_name = optional(string, "sae-headless-slb")<br/>    vswitch_key        = string<br/>    load_balancer_spec = string<br/>    address_type       = string<br/>  }))</pre> | `{}` | no |
| <a name="input_vpc_config"></a> [vpc\_config](#input\_vpc\_config) | Configuration for VPC. The attribute 'cidr\_block' is required. | <pre>object({<br/>    cidr_block = string<br/>    vpc_name   = optional(string, "sae-headless-vpc")<br/>  })</pre> | <pre>{<br/>  "cidr_block": "192.168.0.0/16"<br/>}</pre> | no |
| <a name="input_vswitches_config"></a> [vswitches\_config](#input\_vswitches\_config) | Configuration for VSwitches. Each VSwitch requires 'cidr\_block' and 'zone\_id'. | <pre>map(object({<br/>    cidr_block   = string<br/>    zone_id      = string<br/>    vswitch_name = optional(string, "sae-headless-vswitch")<br/>  }))</pre> | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_backend_internal_address"></a> [backend\_internal\_address](#output\_backend\_internal\_address) | The backend internal address for inter-service communication |
| <a name="output_config_map_id"></a> [config\_map\_id](#output\_config\_map\_id) | The ID of the SAE config map |
| <a name="output_frontend_web_url"></a> [frontend\_web\_url](#output\_frontend\_web\_url) | The frontend web URL for accessing the application |
| <a name="output_sae_application_ids"></a> [sae\_application\_ids](#output\_sae\_application\_ids) | Map of SAE application IDs |
| <a name="output_sae_namespace_id"></a> [sae\_namespace\_id](#output\_sae\_namespace\_id) | The ID of the SAE namespace |
| <a name="output_sae_namespace_name"></a> [sae\_namespace\_name](#output\_sae\_namespace\_name) | The name of the SAE namespace |
| <a name="output_security_group_ids"></a> [security\_group\_ids](#output\_security\_group\_ids) | Map of security group IDs |
| <a name="output_slb_load_balancer_addresses"></a> [slb\_load\_balancer\_addresses](#output\_slb\_load\_balancer\_addresses) | Map of SLB load balancer addresses |
| <a name="output_slb_load_balancer_ids"></a> [slb\_load\_balancer\_ids](#output\_slb\_load\_balancer\_ids) | Map of SLB load balancer IDs |
| <a name="output_vpc_cidr_block"></a> [vpc\_cidr\_block](#output\_vpc\_cidr\_block) | The CIDR block of the VPC |
| <a name="output_vpc_id"></a> [vpc\_id](#output\_vpc\_id) | The ID of the VPC |
| <a name="output_vswitch_ids"></a> [vswitch\_ids](#output\_vswitch\_ids) | Map of VSwitch IDs |
<!-- END_TF_DOCS -->

## Submit Issues

If you have any problems when using this module, please opening
a [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) and let us know.

**Note:** There does not recommend opening an issue on this repo.

## Authors

Created and maintained by Alibaba Cloud Terraform Team(terraform@alibabacloud.com).

## License

MIT Licensed. See LICENSE for full details.

## Reference

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)