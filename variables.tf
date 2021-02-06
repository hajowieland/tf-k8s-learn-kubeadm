variable "owner" {
  description = "Tag 'Owner' to be used for all resources"
  type        = string
}

variable "ubuntu_release" {
  description = "Ubuntu release name and version for AMI data source search (`<short-name>-<version-number>`)"
  type        = string
  default     = "bionic-18.04"
}

variable "timezone" {
  description = "TImezone to set for alle instances"
  type        = string
  default     = "Europe/Berlin"
}

variable "ssh_private_key_path" {
  description = "SSH Private Key path on your workstatio (must match 'key_pair_name' SSH Key)"
  type        = string
  default     = "$HOME/.ssh/id_rsa" #tfsec:ignore:GEN001
}

variable "key_pair_name" {
  description = "Preexisting AWS Key Pair name for SSH (leave emty to generate new AWS Key Pair)"
  type        = string
  default     = ""
}

variable "etcd_version" {
  description = "etcd / etcdctl version to install in UserData"
  type        = string
  default     = "v3.4.13"
}

variable "cfssl_version" {
  description = "cfssl version to install in UserData"
  type        = string
  default     = "1.4.1"
}

variable "aws_region" {
  description = "AWS Region to use for all resources"
  type        = string
  default     = "eu-central-1"
}

variable "number_azs" {
  description = "Number of AWS Availability Zones to use for every subnet"
  type        = number
  default     = 3
}

variable "vpc_cidr" {
  description = "AWS VPC CIDR network block (e.g. `10.0.0.0/16`)"
  type        = string
  default     = "10.0.0.0/16"
}

variable "bastion_instance_type" {
  description = "Bastion: EC2 Instance Type"
  type        = string
  default     = "t3a.small"
}

variable "controller_instance_type" {
  description = "controller: EC2 Instance Type"
  type        = string
  default     = "t3a.small"
}

variable "worker_instance_type" {
  description = "Worker: EC2 Instance Type"
  type        = string
  default     = "t3a.small"
}

variable "etcd_instance_type" {
  description = "etcd: EC2 Instance Type"
  type        = string
  default     = "t3a.small"
}

variable "bastion_volume_size" {
  description = "bastion - EBS root volume size in GB"
  type        = number
  default     = 30
}

variable "controller_volume_size" {
  description = "controller - EBS root volume size in GB"
  type        = number
  default     = 30
}

variable "worker_volume_size" {
  description = "Worker - EBS root volume size in GB"
  type        = number
  default     = 30
}

variable "etcd_volume_size" {
  description = "etcd - EBS root volume size in GB"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default = {
    ManagedBy = "terraform"
    Project   = "cka-kubeadm"
    Name      = "cka-kubeadm"
  }
}
