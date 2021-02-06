output "ami" {
  description = "AMI description"
  value       = data.aws_ami.ubuntu.description
}

output "workstation_ip" {
  description = "Your workstation's IP address"
  value       = chomp(data.http.myip.body)
}

output "bastion_public_ip" {
  description = "Bastion Host Public IPv4 address to connect to"
  value       = aws_instance.bastion.public_ip
}

output "lb_kube_apiserver_dns" {
  description = "kube-apiserver Load Balancer DNS"
  value       = aws_elb.kube_apiserver.dns_name
}

output "lb_etcd_dns" {
  description = "etcd Load Balancer DNS"
  value       = aws_elb.etcd.dns_name
}