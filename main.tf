locals {
  tags = merge(
    var.tags,
    map(
      "Owner", var.owner
    )
  )
}

# --------------------------------------------------------------------------
# Data sources
# --------------------------------------------------------------------------
data "aws_availability_zones" "available" {}
data "aws_region" "current" {}

data "http" "myip" {
  url = "http://ipv4.icanhazip.com"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-${var.ubuntu_release}-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}


# --------------------------------------------------------------------------
# OPTIONAL: AWS Key Pair
# --------------------------------------------------------------------------
resource "aws_key_pair" "keypair" {
  count = var.key_pair_name == "" ? 1 : 0

  key_name   = "${var.owner}-ssh"
  public_key = file("${var.ssh_private_key_path}.pub")

  tags = local.tags
}

# --------------------------------------------------------------------------
# Load Balancer for etcd
# --------------------------------------------------------------------------
resource "aws_elb" "etcd" {
  name_prefix = "k8setc"
  internal    = true
  subnets     = aws_subnet.private.*.id

  listener {
    instance_port     = 2379
    instance_protocol = "TCP"
    lb_port           = 2379
    lb_protocol       = "TCP"
  }

  listener {
    instance_port     = 2380
    instance_protocol = "TCP"
    lb_port           = 2380
    lb_protocol       = "TCP"
  }

  health_check {
    healthy_threshold   = 2
    interval            = 5
    target              = "TCP:22"
    timeout             = 3
    unhealthy_threshold = 10

  }

  instances                 = aws_instance.etcd.*.id
  cross_zone_load_balancing = true
  security_groups           = [aws_security_group.lb_etcd.id]


  tags = local.tags
}

# --------------------------------------------------------------------------
# Load Balancer for kube-apiserver
# --------------------------------------------------------------------------
resource "aws_elb" "kube_apiserver" {
  name_prefix = "k8sapi"
  internal    = true
  subnets     = aws_subnet.private.*.id

  listener {
    instance_port     = 6443
    instance_protocol = "TCP"
    lb_port           = 6443
    lb_protocol       = "TCP"
  }

  health_check {
    healthy_threshold   = 2
    interval            = 5
    target              = "TCP:22"
    timeout             = 3
    unhealthy_threshold = 10

  }

  instances                 = aws_instance.controller.*.id
  cross_zone_load_balancing = true
  security_groups           = [aws_security_group.lb_kube_apiserver.id]


  tags = local.tags
}


# --------------------------------------------------------------------------
# EC2 - bastion
# --------------------------------------------------------------------------
resource "aws_instance" "bastion" {
  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = true #tfsec:ignore:AWS012
  instance_type               = var.bastion_instance_type
  key_name                    = var.key_pair_name != "" ? var.key_pair_name : aws_key_pair.keypair[0].key_name
  subnet_id                   = aws_subnet.public.0.id
  vpc_security_group_ids      = [aws_security_group.bastion.id]
  iam_instance_profile        = aws_iam_instance_profile.k8s.name

  user_data = base64encode(templatefile("${path.module}/user_data_bastion.sh", {
    etcd_version    = var.etcd_version
    cfssl_version   = var.cfssl_version
    timezone        = var.timezone
    private_key     = file(var.ssh_private_key_path)
    etcd_1_ip       = aws_instance.etcd.0.private_ip
    etcd_2_ip       = aws_instance.etcd.1.private_ip
    etcd_3_ip       = aws_instance.etcd.2.private_ip
    controller_1_ip = aws_instance.controller.0.private_ip
    controller_2_ip = aws_instance.controller.1.private_ip
    controller_3_ip = aws_instance.controller.2.private_ip
    worker_1_ip     = aws_instance.worker.0.private_ip
    worker_2_ip     = aws_instance.worker.1.private_ip
    worker_3_ip     = aws_instance.worker.2.private_ip
  }))

  root_block_device {
    encrypted   = true
    volume_size = var.bastion_volume_size

    tags = local.tags
  }

  tags = merge(
    local.tags,
    map(
      "Name", "bastion"
    )
  )
}


# --------------------------------------------------------------------------
# EC2 - controllers
# --------------------------------------------------------------------------
resource "aws_instance" "controller" {
  count = 3

  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = false
  instance_type               = var.controller_instance_type
  key_name                    = var.key_pair_name != "" ? var.key_pair_name : aws_key_pair.keypair[0].key_name
  subnet_id                   = aws_subnet.private[count.index].id
  vpc_security_group_ids      = [aws_security_group.controller.id]
  iam_instance_profile        = aws_iam_instance_profile.k8s.name
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    etcd_version  = var.etcd_version
    cfssl_version = var.cfssl_version
    timezone      = var.timezone
  }))

  root_block_device {
    encrypted   = true
    volume_size = var.controller_volume_size

    tags = local.tags
  }

  tags = merge(
    local.tags,
    map(
      "Name", "controller-${count.index}"
    )
  )
}


# --------------------------------------------------------------------------
# EC2 - workers
# --------------------------------------------------------------------------
resource "aws_instance" "worker" {
  count = 3

  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = false
  instance_type               = var.worker_instance_type
  key_name                    = var.key_pair_name != "" ? var.key_pair_name : aws_key_pair.keypair[0].key_name
  subnet_id                   = aws_subnet.private[count.index].id
  vpc_security_group_ids      = [aws_security_group.worker.id]
  iam_instance_profile        = aws_iam_instance_profile.k8s.name
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    etcd_version  = var.etcd_version
    cfssl_version = var.cfssl_version
    timezone      = var.timezone
  }))

  root_block_device {
    encrypted   = true
    volume_size = var.worker_volume_size

    tags = local.tags
  }

  tags = merge(
    local.tags,
    map(
      "Name", "worker-${count.index}"
    )
  )
}

# --------------------------------------------------------------------------
# EC2 - etcd
# --------------------------------------------------------------------------
resource "aws_instance" "etcd" {
  count = 3

  ami                         = data.aws_ami.ubuntu.id
  associate_public_ip_address = false
  instance_type               = var.etcd_instance_type
  key_name                    = var.key_pair_name != "" ? var.key_pair_name : aws_key_pair.keypair[0].key_name
  subnet_id                   = aws_subnet.private[count.index].id
  vpc_security_group_ids      = [aws_security_group.etcd.id]
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    etcd_version  = var.etcd_version
    cfssl_version = var.cfssl_version
    timezone      = var.timezone
  }))

  root_block_device {
    encrypted   = true
    volume_size = var.etcd_volume_size

    tags = local.tags
  }

  tags = merge(
    local.tags,
    map(
      "Name", "etcd-${count.index}"
    )
  )
}