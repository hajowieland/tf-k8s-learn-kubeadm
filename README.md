# tf-k8s-learn-kubeadm

This Terraform module creates AWS resources to learn for CKA and experiment with kubeadm / self-managed K8s.

## Resources

* _OPTIONAL:_ **AWS Key Pair** (you can use a pre-existing one, too)
* **VPC**
  * Public Subnets
    * Internet Gateway
  * Private Subnets
    * NAT Gateway (single one for all AZs to save costs)
* **Classic Load Balancer**
  * etcd
  * kube-apiserver
* **UserData**
  * [ssh-multi.sh](https://gist.github.com/dmytro/3984680) tmux script
  * Install useful tools:
    * [curl](https://curl.se)
    * [etcdctl](https://github.com/etcd-io/etcd/tree/master/etcdctl)
    * [jq](https://stedolan.github.io/jq/)
    * [wget](https://www.gnu.org/software/wget/)
    * [yq](https://mikefarah.gitbook.io/yq/)
* **EC2 Instances** _(NO AUTOSCALING!)_
  * Bastion (provisioned with your private SSH Key and populated SSH Config)
  * etcd
  * controller
  * worker



## Examples

Set variables in your local `terraform.tfvars` file to match your needs.

Use Ubuntu 20.04 LTS instead of default 18.04 and pre-existing AWS Key Pair and SSH Key path:
```hcl
owner                = "johndoe"
ssh_private_key_path = "$HOME/.ssh/id_rsa-customkey"
key_pair_name        = "my-key-pair-name"
ubuntu_release       = "focal-20.04"
```

Set custom instance types (default: `t3a.small`):
````hcl
owner                 = "johndoe"
bastion_instance_type = "t3a.micro"
etcd_instance_type    = "t3a.medium"
master_instance_type  = "t3a.medium"
worker_instance_type  = "t3a.large"
````

## Terraform Docs
<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| aws | n/a |
| http | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| aws\_region | AWS Region to use for all resources | `string` | `"eu-central-1"` | no |
| bastion\_instance\_type | Bastion: EC2 Instance Type | `string` | `"t3a.small"` | no |
| bastion\_volume\_size | bastion - EBS root volume size in GB | `number` | `30` | no |
| cfssl\_version | cfssl version to install in UserData | `string` | `"1.4.1"` | no |
| controller\_instance\_type | controller: EC2 Instance Type | `string` | `"t3a.small"` | no |
| controller\_volume\_size | controller - EBS root volume size in GB | `number` | `30` | no |
| etcd\_instance\_type | etcd: EC2 Instance Type | `string` | `"t3a.small"` | no |
| etcd\_version | etcd / etcdctl version to install in UserData | `string` | `"v3.4.13"` | no |
| etcd\_volume\_size | etcd - EBS root volume size in GB | `number` | `30` | no |
| key\_pair\_name | Preexisting AWS Key Pair name for SSH (leave emty to generate new AWS Key Pair) | `string` | `""` | no |
| number\_azs | Number of AWS Availability Zones to use for every subnet | `number` | `3` | no |
| owner | Tag 'Owner' to be used for all resources | `string` | n/a | yes |
| ssh\_private\_key\_path | SSH Private Key path on your workstatio (must match 'key\_pair\_name' SSH Key) | `string` | `"$HOME/.ssh/id_rsa"` | no |
| tags | Tags to apply to resources | `map(string)` | <pre>{<br>  "ManagedBy": "terraform",<br>  "Name": "cka-kubeadm",<br>  "Project": "cka-kubeadm"<br>}</pre> | no |
| timezone | TImezone to set for alle instances | `string` | `"Europe/Berlin"` | no |
| ubuntu\_release | Ubuntu release name and version for AMI data source search (`<short-name>-<version-number>`) | `string` | `"bionic-18.04"` | no |
| vpc\_cidr | AWS VPC CIDR network block (e.g. `10.0.0.0/16`) | `string` | `"10.0.0.0/16"` | no |
| worker\_instance\_type | Worker: EC2 Instance Type | `string` | `"t3a.small"` | no |
| worker\_volume\_size | Worker - EBS root volume size in GB | `number` | `30` | no |

## Outputs

| Name | Description |
|------|-------------|
| ami | AMI description |
| bastion\_public\_ip | Bastion Host Public IPv4 address to connect to |
| lb\_etcd\_dns | etcd Load Balancer DNS |
| lb\_kube\_apiserver\_dns | kube-apiserver Load Balancer DNS |
| workstation\_ip | Your workstation's IP address |

<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
