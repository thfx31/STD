resource "aws_ecr_repository" "std_chat" {
  name                 = "std-chat"
  image_tag_mutability = "MUTABLE"
}
