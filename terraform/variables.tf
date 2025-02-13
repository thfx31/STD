variable "region" {
  description = "Région AWS où déployer les ressources"
  type        = string
  default     = "eu-west-1"
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
