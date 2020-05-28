resource "aws_key_pair" "deployer" {
  key_name   = var.domain_name
  public_key = file("${var.pub_key_path}")
}

