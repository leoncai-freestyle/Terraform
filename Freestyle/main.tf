resource "aws_instance" "my-test-instance" {
  ami             = "${data.aws_ami.ubuntu.id}"
  instance_type   = "t2.micro"
  key_name = "${aws_key_pair.pubkey.key_name}"


  # the VPC subnet
  subnet_id = "${aws_subnet.main-public-1.id}"

  # the security group
  vpc_security_group_ids = ["${aws_security_group.allow-ssh-http.id}"]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p "${var.SERVER_PORT}" &
              EOF

  tags {
    Name = "test-instance"
  }

  provisioner "file" {
    source = "script.sh"
    destination = "/tmp/script.sh"
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/script.sh",
      "sudo /tmp/script.sh"
    ]
  }
  connection {
    user = "${var.INSTANCE_USERNAME}"
    private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
  }

}

output "ip" {
    value = "${aws_instance.my-test-instance.public_ip}"
}

#Using https://registry.terraform.io/modules/terraform-aws-modules

module "ec2_cluster" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name           = "my-cluster"
  instance_count = 1

  ami                    = "${data.aws_ami.ubuntu.id}"
  instance_type          = "t2.micro"
  key_name               = "${aws_key_pair.pubkey.key_name}"
  monitoring             = true
  associate_public_ip_address = true

  # the security group
  vpc_security_group_ids = ["${aws_security_group.allow-ssh-http.id}"]

  # the VPC subnet
  subnet_id = "${aws_subnet.main-public-1.id}"

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              apt-get install nginx -y
              service nginx start
              echo "ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAgEAi8TZaOHZYAmWM6Devr6rqDh/Eb7Y2Emie6X3lQZQpGQRr4+tGvfyQ923li3gwUya2czxqVWbwD9hHjt4ODM5wN0wVgTJFGaYj9ejN1aZnneN5koUJwBwB7hjCna9eMG78i4PwBiIHEAMHJq5lhGOoSueIRttc3I1egqDCaz6Vwh37RMjXHI2Da+cq2894qbNJAiEZGrfX3fFoy29bBOwx1VgCa4X5Sk8a06huwDiWY922C35SGjyqTD0XYjgskMbYXjXOC3+umKXqGp/wytR7XqZmfJGgfmKRuA70DfTgDmqLvTxkr2J9LTh3ulqXOfzYo5LWZq1nR39h01fvlhUPLb8DUDY0QeMCRgim2Oq6VZCOZFqt/MKKoBmcl9RS2/ALGJK0r5gh1/heWPcEPB0N1jr07o+1C5TZsGWNIpWQKY/F/pa3zAH5l25W2GuXo9gHifBR2SWDbjRTbtyEjdzwKywQssMG2xLqJnrDoPWKYkBpA5B9bQKHNbI0r6Bwu1Q/RJuc1GnkmlKkWMWUMI8ByEFwlj2+G2vD6up2HXq5xR/JJdCfpqNPb73ZYHsavDHylNSYN9EbYM6gC0lwbzpb9CH8qdHFoxcPgNOux5zJFwPDy6HvRaYk8mqc+eRJAoLAlWoB2eY1BGC8odHPd29GbTqYKe0nKolUCbzfBgdSSE= david" >> /home/ubuntu/.ssh/authorized_keys
              echo "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC5GB4SdBq70isqpvCltCDDANn5hkALdz6rJNMQIgA7dtEbuom3k2TT5CwBjKYEwSVzcc1d7M3JTlG0cO3CgBTh0+/UcZehhwVLmdeAijC82oYNuBa8xelsQJK8x39t0vTE5YG3UEzAM5cZtoeOKiEMUnzOpuucNmGxiXPkO4R0oE86eGQhjV5yIgAGN8o8XyWZ8D7Jm/REvxpWb/IBv1SnoG7fpkOS7XsREvtnDlcYZEDqJRAdnOGLlUIMQFftpJjNZeiLhnin7GB1QdiUxgOU1n7hWKDMG8OI3lCFhUtYPEwdd9upE5Y6sNwjeClKEmpR6va+MuIi2AkyVe0AuCAd leon" >>  /home/ubuntu/.ssh/authorized_keys
              nohup busybox httpd -f -p "${var.SERVER_PORT}" &
              EOF

  tags = {
    Terraform = "true"
    Environment = "dev"
  }
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = "${module.ec2_cluster.id[0]}"
}

output "instance_public_dns" {
  description = "Public DNS name assigned to the EC2 instance"
  value       = "${module.ec2_cluster.public_dns[0]}"
}

output "instance_public_ip" {
  description = "EC2 instance PublicIP"
  value       = "${module.ec2_cluster.public_ip[0]}"
}
