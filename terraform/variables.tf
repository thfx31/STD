variable "aws_region" {
  description = "La région AWS où déployer les ressources"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "Type d'instance pour l'EC2"
  type        = string
  default     = "t2.micro"
}

variable "key_name" {
  description = "Nom de la clé SSH pour accéder aux instances"
  type        = string
  default     = "SRE-KeyPair"
}

variable "instance_name" {
  description = "Nom du tag pour l'instance"
  type        = string
  default     = "STD-EC2"
}
