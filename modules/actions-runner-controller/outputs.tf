output "namespace" {
  value = helm_release.actions_runner_controller.namespace
}

output "github_webhook_server_address" {
  value = data.kubernetes_service.github_webhook_server.status.0.load_balancer.0.ingress.0.ip
}
