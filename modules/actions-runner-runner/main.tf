terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">=2.5.1"
    }
  }
}

resource "kubernetes_manifest" "runner" {
  manifest = {
    "apiVersion" = "actions.summerwind.dev/v1alpha1"
    "kind"       = "RunnerDeployment"
    "metadata" = {
      "name"      = "actions-runner"
      "namespace" = var.namespace
    }
    "spec" = {
      "template" = {
        "spec" = {
          "repository" = var.control_repo_nwo
          "image"      = "ghcr.io/covid-policy-modelling/actions-runner/actions-runner:${var.runner_version}"
          "ephemeral"  = "true"
          "resources" = {
            "requests" = {
              "cpu" : "500m"
              "memory" : "4G"
            }
          }
          # There are some intermittent failures because the sidecar container is not up in time,
          # with the error: "Error: unable to resolve docker endpoint: open /certs/client/ca.pem: no such file or directory"
          # This adds a delay to mitigate that, until a better approach is possible:
          # https://github.com/actions-runner-controller/actions-runner-controller/issues/787
          "env" = [
            {
              "name"  = "STARTUP_DELAY_IN_SECONDS"
              "value" = "30"
            }
          ]
        }
      }
    }
  }
}

resource "kubernetes_manifest" "autoscale" {
  manifest = {
    "apiVersion" = "actions.summerwind.dev/v1alpha1"
    "kind"       = "HorizontalRunnerAutoscaler"
    "metadata" = {
      "name"      = "${kubernetes_manifest.runner.manifest.metadata.name}-autoscale"
      "namespace" = kubernetes_manifest.runner.manifest.metadata.namespace
    }
    "spec" = {
      "scaleTargetRef" = {
        "name" = kubernetes_manifest.runner.manifest.metadata.name
      }
      "minReplicas" = 0
      "maxReplicas" = var.max_runners
      "scaleUpTriggers" = [
        {
          "githubEvent" = {}
          "duration"    = "5m"
        }
      ]
    }
  }
}
