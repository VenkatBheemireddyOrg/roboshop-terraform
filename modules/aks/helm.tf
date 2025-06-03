resource "null_resource" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.main]
  provisioner "local-exec" {
    command = <<EOF
az login --service-principal --username ${data.vault_generic_secret.az.data["ARM_CLIENT_ID"]} --password ${data.vault_generic_secret.az.data["ARM_CLIENT_SECRET"]} --tenant ${data.vault_generic_secret.az.data["ARM_TENANT_ID"]}

az aks get-credentials --resource-group ${data.azurerm_resource_group.main.name} --name main --overwrite-existing
EOF
  }
}


resource "helm_release" "external-secrets" {
  depends_on = [null_resource.kubeconfig]
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  chart      = "external-secrets"
  namespace  = "kube-system"
}


resource "null_resource" "external-secrets" {
  depends_on = [helm_release.external-secrets]
  provisioner "local-exec" {
    command = <<EOF
kubectl create secret generic vault-token --from-literal=token=${var.vault_token}
kubectl apply -f ${path.module}/files/secretstore.yaml
EOF
  }
}
#kubectl apply -f /opt/vault-token.yml


resource "null_resource" "argocd" {
  depends_on = [null_resource.kubeconfig]
  provisioner "local-exec" {
    command = <<EOF
kubectl apply -f ${path.module}/files/argocd-ns.yaml
kubectl apply -f ${path.module}/files/argocd.yaml -n argocd
EOF
  }
}


# installation of prometheus
resource "helm_release" "prometheus" {
  depends_on = [null_resource.kubeconfig]
  name       = "pstack"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "kube-system"
}


# installation of nginx-ingress controller
# This chart is not working - https://github.com/kubernetes/ingress-nginx/issues/10863
# resource "helm_release" "nginx-ingress" {
#   depends_on = [null_resource.kubeconfig]
#   name       = "ingress-nginx"
#   repository = "https://kubernetes.github.io/ingress-nginx"
#   chart      = "ingress-nginx"
#   namespace  = "kube-system"
# }


resource "null_resource" "nginx-ingress" {
  depends_on = [null_resource.kubeconfig]
  provisioner "local-exec" {
    command = <<EOF
 kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.8.2/deploy/static/provider/cloud/deploy.yaml
EOF
  }
}


resource "null_resource" "external-dns-secret" {
  depends_on = [null_resource.kubeconfig]
  provisioner "local-exec" {
    command = <<EOT
cat <<-EOF > ${path.module}/azure.json
{
  "tenantId": "${data.azurerm_subscription.current.tenant_id}",
  "subscriptionId": "${data.azurerm_subscription.current.subscription_id}",
  "resourceGroup": "${data.azurerm_resource_group.main.name}",
  "useManagedIdentityExtension": true
}
EOF
kubectl create secret generic azure-config-file --namespace "kube-system" --from-file=${path.module}/azure.json
EOT
  }
}
# "userAssignedIdentityID": "${azurerm_kubernetes_cluster.main.kubelet_identity[0].client_id}"

# installing external-dns installation
resource "helm_release" "external-dns" {
  depends_on = [null_resource.kubeconfig]
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace  = "kube-system"
  values = [
    file("${path.module}/files/external-dns.yml")
  ]
}

