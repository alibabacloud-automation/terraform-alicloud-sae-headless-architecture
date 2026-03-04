output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.sae_headless_architecture.vpc_id
}

output "frontend_web_url" {
  description = "The frontend web URL for accessing the application"
  value       = module.sae_headless_architecture.frontend_web_url
}

output "backend_internal_address" {
  description = "The backend internal address for inter-service communication"
  value       = module.sae_headless_architecture.backend_internal_address
}

output "sae_namespace_id" {
  description = "The ID of the SAE namespace"
  value       = module.sae_headless_architecture.sae_namespace_id
}

output "sae_application_ids" {
  description = "Map of SAE application IDs"
  value       = module.sae_headless_architecture.sae_application_ids
}

output "slb_load_balancer_addresses" {
  description = "Map of SLB load balancer addresses"
  value       = module.sae_headless_architecture.slb_load_balancer_addresses
}