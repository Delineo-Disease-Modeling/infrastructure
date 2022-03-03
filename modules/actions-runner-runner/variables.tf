variable "control_repo_nwo" {
  type        = string
  description = "The name (with owner) of the control-plane repo"
}

variable "namespace" {
  type        = string
  description = "The namespace containing the actions-runner-controller"
}

variable "max_runners" {
  type        = number
  description = "The maximum number of runners to allow at any one time"
}

variable "runner_version" {
  type        = string
  description = "Version of actions-runner container to use"
}
