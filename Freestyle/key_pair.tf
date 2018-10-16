resource "aws_key_pair" "pubkey" {
  key_name   = "pubkey"
  public_key = "${file("key.pub")}"
}

