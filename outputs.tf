output "vpc_id" {
  description = "The ID of the VPC"
  value       = alicloud_vpc.vpc.id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = alicloud_vpc.vpc.cidr_block
}

output "vswitch_ids" {
  description = "Map of VSwitch IDs"
  value       = { for k, v in alicloud_vswitch.vswitches : k => v.id }
}

output "security_group_ids" {
  description = "Map of security group IDs"
  value       = { for k, v in alicloud_security_group.security_groups : k => v.id }
}

output "sae_namespace_id" {
  description = "The ID of the SAE namespace"
  value       = alicloud_sae_namespace.sae_namespace.id
}

output "sae_namespace_name" {
  description = "The name of the SAE namespace"
  value       = alicloud_sae_namespace.sae_namespace.namespace_name
}

output "config_map_id" {
  description = "The ID of the SAE config map"
  value       = alicloud_sae_config_map.nginx_config_map.id
}

output "sae_application_ids" {
  description = "Map of SAE application IDs"
  value       = { for k, v in alicloud_sae_application.sae_applications : k => v.id }
}

output "slb_load_balancer_ids" {
  description = "Map of SLB load balancer IDs"
  value       = { for k, v in alicloud_slb_load_balancer.slb_load_balancers : k => v.id }
}

output "slb_load_balancer_addresses" {
  description = "Map of SLB load balancer addresses"
  value       = { for k, v in alicloud_slb_load_balancer.slb_load_balancers : k => v.address }
}

output "frontend_web_url" {
  description = "The frontend web URL for accessing the application"
  value       = try("http://${alicloud_slb_load_balancer.slb_load_balancers["frontend"].address}", null)
}

output "backend_internal_address" {
  description = "The backend internal address for inter-service communication"
  value       = try(alicloud_slb_load_balancer.slb_load_balancers["backend"].address, null)
}