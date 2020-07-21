variable "token" {
  description = "Name of EFS token"
  type        = string
}

variable "subnet" {
  description = "Name of subnet on which Mount point is created"
  type        = string
}

variable "tags" {
  description = "Tags to set on the EFS"
  type        = map(string)
}

variable "security_groups" {
  description = "security to set on the EFS"
  type        = list(string)
}
