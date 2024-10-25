module "cert-manager-terraform-k8s-namespace" {
  source = "../modules/terraform-k8s-namespace/"
  name   = "cert-manager"
}

module "cert-mananger-terraform-helm" {
  source               = "../modules/terraform-helm/"
  deployment_name      = "cert-manager"
  deployment_namespace = module.cert-manager-terraform-k8s-namespace.namespace
  chart                = "cert-manager"
  chart_version        = var.cert-manager-config["chart_version"]
  repository           = "https://charts.jetstack.io"
  values_yaml          = <<EOF
podDnsPolicy: "None"
podDnsConfig:
  nameservers:
    - "8.8.4.4"
    - "8.8.8.8"
installCRDs: true
EOF
}

module "lets-encrypt" {
  depends_on = [
    module.cert-mananger-terraform-helm
  ]
  source               = "../modules/terraform-helm-local/"
  deployment_name      = "lets-encrypt"
  deployment_namespace = "cert-manager"
  deployment_path      = "charts/lets-encrypt"
  values_yaml          = <<EOF
email: "${var.email}"
domain_name: "${var.domain_name}"
EOF
}