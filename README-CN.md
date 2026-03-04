阿里云 SAE 无头架构 Terraform 模块

# terraform-alicloud-sae-headless-architecture

[English](https://github.com/alibabacloud-automation/terraform-alicloud-sae-headless-architecture/blob/main/README.md) | 简体中文

使用阿里云 Serverless 应用引擎 (SAE) 创建完整无头架构解决方案的 Terraform 模块。该模块实现了[10分钟完成前后端分离架构升级（SAE版）](https://www.aliyun.com/solution/tech-solution-deploy/2866912)解决方案，支持前后端分离架构，包含 SAE 应用、负载均衡器和支撑基础设施。该解决方案为构建具有分离前端和后端服务的现代化 Web 应用程序提供了可扩展的无服务器方法。

## 使用方法

该模块创建基于 SAE 的完整无头架构，包括 VPC、交换机、安全组、SAE 命名空间、应用程序和负载均衡器。适用于需要部署前端和后端应用程序并实现适当分离和负载均衡的场景。

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

  # VPC 配置
  vpc_config = {
    cidr_block = "192.168.0.0/16"
  }

  # 交换机配置
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

  # 安全组配置
  security_groups_config = {
    "frontend" = {
      description = "前端应用安全组"
    }
    "backend" = {
      description = "后端应用安全组"
    }
  }

  # SAE 命名空间配置
  sae_namespace_config = {
    namespace_id              = "${data.alicloud_regions.current.regions[0].id}:${random_string.suffix.result}"
    enable_micro_registration = false
  }

  # SAE 应用配置
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

  # SLB 负载均衡器配置
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

  # SAE 公网 SLB 配置
  sae_internet_slb_config = {
    "frontend" = {
      app_key     = "frontend"
      slb_key     = "frontend"
      protocol    = "HTTP"
      port        = 80
      target_port = 80
    }
  }

  # SAE 内网 SLB 配置
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

## 示例

* [完整示例](https://github.com/alibabacloud-automation/terraform-alicloud-sae-headless-architecture/tree/main/examples/complete)

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

## 提交问题

如果您在使用此模块时遇到任何问题，请提交一个 [provider issue](https://github.com/aliyun/terraform-provider-alicloud/issues/new) 并告知我们。

**注意：** 不建议在此仓库中提交问题。

## 作者

由阿里云 Terraform 团队创建和维护(terraform@alibabacloud.com)。

## 许可证

MIT 许可。有关完整详细信息，请参阅 LICENSE。

## 参考

* [Terraform-Provider-Alicloud Github](https://github.com/aliyun/terraform-provider-alicloud)
* [Terraform-Provider-Alicloud Release](https://releases.hashicorp.com/terraform-provider-alicloud/)
* [Terraform-Provider-Alicloud Docs](https://registry.terraform.io/providers/aliyun/alicloud/latest/docs)