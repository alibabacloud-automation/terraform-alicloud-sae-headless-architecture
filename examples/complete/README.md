# Complete Example

This example demonstrates how to use the SAE Headless Architecture module to deploy a complete frontend-backend separation solution on Alibaba Cloud.

## Architecture

This example creates:

- A VPC with 4 VSwitches across 2 availability zones
- 2 Security Groups (frontend and backend)
- 1 SAE Namespace
- 2 SAE Applications (frontend and backend)
- 2 SLB Load Balancers (internet and intranet)
- ConfigMap for nginx configuration

## Usage

To run this example, execute the following commands:

```bash
$ terraform init
$ terraform plan
$ terraform apply
```

**Note**: This example may create resources that cost money. Run `terraform destroy` when you no longer need these resources.

## Configuration

### Required Variables

- `region`: The Alibaba Cloud region where resources will be created (default: "cn-hangzhou")

### Optional Customization

You can customize the deployment by modifying the module configuration in `main.tf`:

- Change VPC CIDR blocks
- Modify application configurations
- Adjust load balancer specifications
- Update SAE application images

## Outputs

After deployment, you will get:

- `frontend_web_url`: The URL to access the frontend application
- `backend_internal_address`: The internal address for backend communication
- `vpc_id`: The ID of the created VPC
- `sae_namespace_id`: The ID of the SAE namespace
- `sae_application_ids`: Map of SAE application IDs
- `slb_load_balancer_addresses`: Map of load balancer addresses

## Clean Up

To destroy the resources:

```bash
terraform destroy
```

## Requirements

- Terraform >= 1.0
- Alibaba Cloud Provider >= 1.200.0
- Valid Alibaba Cloud credentials configured