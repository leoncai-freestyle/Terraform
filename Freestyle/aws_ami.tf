data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["freestyle-standard"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["068878084735"] # Canonical
}
