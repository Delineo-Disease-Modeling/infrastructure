terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">=2.3.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.5.1"
    }
  }
}

resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  version          = "1.5.4"
  namespace        = "cert-manager"
  create_namespace = true
  wait             = true

  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "actions_runner_controller" {
  name             = "actions-runner-controller"
  repository       = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart            = "actions-runner-controller"
  namespace        = "actions-runner-system"
  create_namespace = true
  wait             = true

  values = [
    templatefile("${path.module}/values.yaml.tpl", {
      github_registration_pat = var.github_registration_pat
      webhook_shared_secret   = var.webhook_shared_secret
    })
  ]

  depends_on = [
    helm_release.cert_manager
  ]
}

data "kubernetes_service" "github_webhook_server" {
  metadata {
    name      = "${helm_release.actions_runner_controller.name}-github-webhook-server"
    namespace = helm_release.actions_runner_controller.namespace
  }
}
