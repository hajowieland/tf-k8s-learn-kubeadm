output "ami" {
  value = data.aws_ami.ubuntu.description
}

output "workstation_ip" {
  value = chomp(data.http.myip.body)
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

output "controller_private_ips" {
  value = aws_instance.controller.*.private_ip
}

output "worker_private_ips" {
  value = aws_instance.worker.*.private_ip
}

output "etcd_private_ips" {
  value = aws_instance.etcd.*.private_ip
}

output "lb_kube_apiserver_dns" {
  value = aws_elb.kube_apiserver.dns_name
}

output "lb_etcd_dns" {
  value = aws_elb.etcd.dns_name
}