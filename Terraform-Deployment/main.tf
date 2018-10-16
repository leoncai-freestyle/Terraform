#Install vpc

module "vpc" {
  source = "./modules/vpc/"
}

data "aws_availability_zones" "all" {}


#Install management tools 
#jenkins
module "jenkins" {
  source = "./modules/jenkins/"
#  subnet_id = "subnet-042af4accd5cef266"


  name            = "jenkins-server"
#  key_pair        = "${aws_key_pair.my-rails-key.key_name}"
  key_pair_key    = "~/.ssh/id_rsa_leon"
#  security_groups = [
#    "${aws_security_group.allow_ssh.name}",
#    "${aws_security_group.allow_outbound.name}"
#  ]

}

