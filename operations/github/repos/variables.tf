variable "token" {
  type = string
  sensitive = true
}

variable "owner" {
  type = string
  default = "ilink-pro"
}

variable "devops-discord-webhook" {
  type = string
}

variable "backend-discord-webhook" {
  type = string
}

variable "frontend-discord-webhook" {
  type = string
}

variable "ui-discord-webhook" {
  type = string
}
