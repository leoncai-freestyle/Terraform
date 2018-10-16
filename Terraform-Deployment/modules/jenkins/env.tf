variable "instance_type" {
  type = "string"
  default = "t2.micro"
}

variable "name" {
  type = "string"
}

variable "key_pair" {
  type = "string"
  default = "pubkey"
}

variable "key_pair_key" {
  type = "string"
}

variable "security_groups" {
  type = "list"
  default = ["sg-0ed9a0825a4fe50d7"]
}
