# --------------------------------------------------------------------------
# SecurityGroup - bastion
# --------------------------------------------------------------------------
resource "aws_security_group" "bastion" {
  name_prefix = "bastion-"
  description = "Bastion Host"
  vpc_id      = aws_vpc.vpc.id

  tags = local.tags
}


resource "aws_security_group_rule" "egress-bastion" {
  description       = "bastion - ALL egress"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
  to_port           = 65535
  type              = "egress"
}


resource "aws_security_group_rule" "workstation-ssh-bastion" {
  description       = "bastion - SSH workstation"
  from_port         = 22
  protocol          = "tcp"
  security_group_id = aws_security_group.bastion.id
  cidr_blocks       = ["${chomp(data.http.myip.body)}/32"]
  to_port           = 22
  type              = "ingress"
}


# --------------------------------------------------------------------------
# SecurityGroup - etcd
# --------------------------------------------------------------------------
resource "aws_security_group" "etcd" {
  name_prefix = "etcd-"
  description = "etcd"
  vpc_id      = aws_vpc.vpc.id

  tags = local.tags
}


resource "aws_security_group_rule" "egress-etcd" {
  description       = "etcd - ALL egress"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.etcd.id
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
  to_port           = 65535
  type              = "egress"
}


resource "aws_security_group_rule" "bastion-ssh-etcd" {
  description              = "etcd - ssh Bastion"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.etcd.id
  source_security_group_id = aws_security_group.bastion.id
  to_port                  = 22
  type                     = "ingress"
}


resource "aws_security_group_rule" "etcd-etcd" {
  description              = "etcd - etcd"
  from_port                = 2379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.etcd.id
  source_security_group_id = aws_security_group.etcd.id
  to_port                  = 2380
  type                     = "ingress"
}

resource "aws_security_group_rule" "bastion-etcd-etcd" {
  description              = "etcd - bastion"
  from_port                = 2379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.etcd.id
  source_security_group_id = aws_security_group.bastion.id
  to_port                  = 2380
  type                     = "ingress"
}


resource "aws_security_group_rule" "controller-etcd-etcd" {
  description              = "etcd - controller"
  from_port                = 2379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.etcd.id
  source_security_group_id = aws_security_group.controller.id
  to_port                  = 2380
  type                     = "ingress"
}


resource "aws_security_group_rule" "etcd-lb-ssh" {
  description              = "etcd - SSH lb_etcd Healthcheck"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.etcd.id
  source_security_group_id = aws_security_group.lb_etcd.id
  to_port                  = 22
  type                     = "ingress"
}

resource "aws_security_group_rule" "etcd-lb" {
  description              = "etcd - lb_kube_apiserver"
  from_port                = 2379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.etcd.id
  source_security_group_id = aws_security_group.lb_kube_apiserver.id
  to_port                  = 2380
  type                     = "ingress"
}


# --------------------------------------------------------------------------
# SecurityGroup - controller
# --------------------------------------------------------------------------
resource "aws_security_group" "controller" {
  name_prefix = "controller-"
  description = "K8s-Controller"
  vpc_id      = aws_vpc.vpc.id

  tags = local.tags
}


resource "aws_security_group_rule" "egress-controller" {
  description       = "controller - ALL egress"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.controller.id
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
  to_port           = 65535
  type              = "egress"
}


resource "aws_security_group_rule" "bastion-ssh-controller" {
  description              = "controller - ssh bastion"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.bastion.id
  to_port                  = 22
  type                     = "ingress"
}

resource "aws_security_group_rule" "controller-kubernetes_api_server" {
  description              = "controller - kubeapi - controller"
  from_port                = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.controller.id
  to_port                  = 6443
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker-kubernetes_api_server" {
  description              = "controller - kubeapi - worker"
  from_port                = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.worker.id
  to_port                  = 6443
  type                     = "ingress"
}

resource "aws_security_group_rule" "bastion-kubernetes_api_server" {
  description              = "controller - kubeapi - bastion"
  from_port                = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.bastion.id
  to_port                  = 6443
  type                     = "ingress"
}


resource "aws_security_group_rule" "controller-etcd" {
  description              = "controller - etcd - controller"
  from_port                = 2379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.controller.id
  to_port                  = 2380
  type                     = "ingress"
}

resource "aws_security_group_rule" "bastion-etcd" {
  description              = "controller - etcd - bastion"
  from_port                = 2379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.bastion.id
  to_port                  = 2380
  type                     = "ingress"
}


resource "aws_security_group_rule" "controller-kubelet" {
  description              = "controller - kubelet - controller"
  from_port                = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.controller.id
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "controller-kube_scheduler" {
  description              = "controller - scheduler - controller"
  from_port                = 10251
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.controller.id
  to_port                  = 10251
  type                     = "ingress"
}


resource "aws_security_group_rule" "controller-kube_controller_manager" {
  description              = "controller - controller_manager - controller"
  from_port                = 10252
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.controller.id
  to_port                  = 10252
  type                     = "ingress"
}


resource "aws_security_group_rule" "controller-lb-ssh" {
  description              = "controller - ssh - lb_kube_apiserver (Healthcheck)"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.lb_kube_apiserver.id
  to_port                  = 22
  type                     = "ingress"
}

resource "aws_security_group_rule" "controller-lb" {
  description              = "controller - kubeapi - lb_kube_apiserver"
  from_port                = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.controller.id
  source_security_group_id = aws_security_group.lb_kube_apiserver.id
  to_port                  = 6443
  type                     = "ingress"
}


# --------------------------------------------------------------------------
# SecurityGroup - workers
# --------------------------------------------------------------------------
resource "aws_security_group" "worker" {
  name_prefix = "worker-"
  description = "K8s-Worker"
  vpc_id      = aws_vpc.vpc.id

  tags = local.tags
}

resource "aws_security_group_rule" "egress-worker" {
  description       = "worker - ALL egress"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.worker.id
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
  to_port           = 65535
  type              = "egress"
}

resource "aws_security_group_rule" "bastion-ssh-worker" {
  description              = "worker - ssh - bastion"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.bastion.id
  to_port                  = 22
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker-self-kubelet" {
  description              = "worker - kubelet"
  from_port                = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.worker.id
  to_port                  = 10250
  type                     = "ingress"
}

resource "aws_security_group_rule" "controller-worker-kubelet" {
  description              = "worker - kubelet - controller"
  from_port                = 10250
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.controller.id
  to_port                  = 10250
  type                     = "ingress"
}


resource "aws_security_group_rule" "worker-self-nodeport" {
  description              = "worker - NodePort"
  from_port                = 30000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.worker.id
  to_port                  = 32767
  type                     = "ingress"
}

resource "aws_security_group_rule" "controller-worker-nodeport" {
  description              = "worker - NodePort - controller"
  from_port                = 30000
  protocol                 = "tcp"
  security_group_id        = aws_security_group.worker.id
  source_security_group_id = aws_security_group.controller.id
  to_port                  = 32767
  type                     = "ingress"
}


# --------------------------------------------------------------------------
# SecurityGroup - Load Balancer kube-apiserver
# --------------------------------------------------------------------------
resource "aws_security_group" "lb_kube_apiserver" {
  name_prefix = "lb-kube-apiserver-"
  description = "Load Balancer - kube-apiserver"
  vpc_id      = aws_vpc.vpc.id

  tags = local.tags
}


resource "aws_security_group_rule" "egress-lb_kube_apiserver" {
  description       = "egress - ALL"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lb_kube_apiserver.id
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
  to_port           = 65535
  type              = "egress"
}

resource "aws_security_group_rule" "controller-lb_kube_apiserver" {
  description              = "lb_kube_apiserver - kubeapi - controller"
  from_port                = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_kube_apiserver.id
  source_security_group_id = aws_security_group.controller.id
  to_port                  = 6443
  type                     = "ingress"
}

resource "aws_security_group_rule" "worker-lb_kube_apiserver" {
  description              = "lb_kube_apiserver - kubeapi - worker"
  from_port                = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_kube_apiserver.id
  source_security_group_id = aws_security_group.worker.id
  to_port                  = 6443
  type                     = "ingress"
}

resource "aws_security_group_rule" "bastion-lb_kube_apiserver" {
  description              = "lb_kube_apiserver - kubeapi - bastion"
  from_port                = 6443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_kube_apiserver.id
  source_security_group_id = aws_security_group.bastion.id
  to_port                  = 6443
  type                     = "ingress"
}

resource "aws_security_group_rule" "controller-lb_kube_apiserver-healthcheck" {
  description              = "lb_kube_apiserver - ssh - controller (Healthcheck)"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_kube_apiserver.id
  source_security_group_id = aws_security_group.controller.id
  to_port                  = 22
  type                     = "ingress"
}


# --------------------------------------------------------------------------
# SecurityGroup - Load Balancer etcd
# --------------------------------------------------------------------------
resource "aws_security_group" "lb_etcd" {
  name_prefix = "lb-etcd-"
  description = "Load Balancer - etcd"
  vpc_id      = aws_vpc.vpc.id

  tags = local.tags
}


resource "aws_security_group_rule" "egress-lb_etcd" {
  description       = "egress - ALL"
  from_port         = 0
  protocol          = "-1"
  security_group_id = aws_security_group.lb_etcd.id
  cidr_blocks       = ["0.0.0.0/0"] #tfsec:ignore:AWS007
  to_port           = 65535
  type              = "egress"
}

resource "aws_security_group_rule" "controller-lb_etcd" {
  description              = "lb_etcd - etcd - controller"
  from_port                = 2379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_etcd.id
  source_security_group_id = aws_security_group.controller.id
  to_port                  = 2380
  type                     = "ingress"
}

resource "aws_security_group_rule" "etcd-lb_etcd" {
  description              = "lb_etcd - etcd - etcd"
  from_port                = 2379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_etcd.id
  source_security_group_id = aws_security_group.etcd.id
  to_port                  = 2380
  type                     = "ingress"
}

resource "aws_security_group_rule" "bastion-lb_etcd" {
  description              = "lb_etcd - etcd - bastion"
  from_port                = 2379
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_etcd.id
  source_security_group_id = aws_security_group.bastion.id
  to_port                  = 2380
  type                     = "ingress"
}

resource "aws_security_group_rule" "etcd-lb_etcd-healthcheck" {
  description              = "lb_etcd - ssh - etcd (Healthcheck)"
  from_port                = 22
  protocol                 = "tcp"
  security_group_id        = aws_security_group.lb_etcd.id
  source_security_group_id = aws_security_group.etcd.id
  to_port                  = 22
  type                     = "ingress"
}
