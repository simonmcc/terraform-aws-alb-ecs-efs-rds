variable "name" {
  type        = string
  description = "prefix for any unique resource"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region"
  default     = "2"
}

variable "app_image" {
  description = "Docker image to run in the ECS cluster"
  default     = "nginx"
}

variable "app_image_tag" {
  description = "Docker Image tag, defaults to latest, allows easy pinning to releases"
  default     = "latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 80
}

variable "app_count" {
  description = "Number of docker containers to run"
  default     = 1
}

variable "health_check_path" {
  default = "/index.html"
}

# cpu & memory combinations need to match definitions given at
# https://docs.aws.amazon.com/AmazonECS/latest/developerguide/task-cpu-memory-error.html

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "256"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "512"
}

variable "private_registry_access_token" {
  type    = map
  default = {}
}

variable "database_username" {
  type    = string
  default = "dbuser"
}
