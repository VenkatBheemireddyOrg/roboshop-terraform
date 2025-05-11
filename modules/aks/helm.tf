resource "null_resource" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.main]
  provisioner "local-exec" {
    command = <<EOF
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

    ###BEG 20250511 added code as part of github-runner workflow
    # kubectl apply -f /opt/vault-token.yml
    kubectl create secret vault-token --from-literal=token=${var.vault_token}
    ###END 20250511 added code as part of github-runner workflow
    EOF
  }
}

resource "null_resource" "argocd" {
  depends_on = [null_resource.kubeconfig]
  provisioner "local-exec" {
    command = <<EOF
       kubectl apply -f ${path.module}/files/argocd-ns.yaml
       kubectl apply -f ${path.module}/files/argocd.yaml
    EOF
  }
}

# ## ArgoCD Setup
# resource "helm_release" "argocd" {
#   depends_on = [null_resource.kubeconfig, helm_release.external-dns]
#
#   name             = "argocd"
#   repository       = "https://argoproj.github.io/argo-helm"
#   chart            = "argo-cd"
#   namespace        = "argocd"
#   create_namespace = true
#   wait             = false
#
#   set {
#     name  = "global.domain"
#     value = "argocd-${var.env}.azdevopsv82.online"
#   }
#
#   values = [
#     file("${path.module}/files/argo-helm.yml")
#   ]
# }



