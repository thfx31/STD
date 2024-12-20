variable "region" {
  description = "Région AWS où déployer les ressources"
  type        = string
  default     = "eu-west-1"
}

variable "instance_type" {
  description = "Type d'instance EC2"
  type        = string
  default     = "t2.micro"
}

variable "vpc_id" {
  description = "ID du VPC où déployer les ressources"
  type        = string
  default     = "vpc-0035b5ae8bbbefd3f"
}

variable "public_subnets" {
  description = "Liste des sous-réseaux pour les instances et le Load Balancer"
  type        = list(string)
  default = ["subnet-02ae3d0545ef9967e",
  "subnet-01bac5268bd103c55"]
}

variable "security_group" {
  description = "ID du Security Group à utiliser"
  type        = string
  default     = "sg-0b92c45c5cd41a041"
}
