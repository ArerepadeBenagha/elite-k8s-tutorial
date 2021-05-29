variable "aws_access_key"  {}
variable "aws_secret_key"  {}
variable "aws_region" {
  default = "us-east-1"
}

variable "amis" {
  type =  map
  default = {
    us-east-1 = "ami-07957d39ebba800d5"  # "ami-048f6ed62451373d9"
    us-west-1 = "ami-0a40aea49c501581d"  # "ami-0ff8a91507f77f867"
  }
}

variable "path_to_public_key" {
  description = "public key"
  default     = "mykey.pub"
}

variable "path_to_private_key" {
  description = "private key"
  default     = "mykey"
}

variable "key_name" {
  description = "Key name for SSHing into EC2"
  default = "mykeypair"
}

variable "instance_tags" {
  type = list
  default = ["elite-vm-master", "elite-vm-agent-a", "elite-vm-agent-b"]
}

variable "instance_eips" {
  type = list
  default = ["elite-vm-master-eip", "elite-vm-agent-eip-a", "elite-vm-agent-eip-b"]
}

variable "instance_type" {
  default = "t2.large"
}

variable "instance_count" {
  type = string
  default = "3"
}

variable "instance_list" {
  type = list
  default = ["i-032b6a3901529f6d0", "i-0e06f3fef9aedf43a"]
}

variable "elite-device-names" {
  default = [
    "/dev/xvdh",
    "/dev/sdd",
    "/dev/sde",
    "/dev/sdf",
   ]
}

variable "elite_ebs_volume_count" {
  type = string
  default = "1"
}

variable "elite_ebs_volume_size" {
  default = 10
}

variable "volume_type" {
  default = "gp2"
}

variable "ports" {
  type = map(list(string))
  default = {
    "22"   = [ "0.0.0.0/0" ]
    "443"  = [ "0.0.0.0/0" ]
    "80"   = [ "0.0.0.0/0" ]
    "8080" = [ "0.0.0.0/0" ]
    "9090" = [ "0.0.0.0/0" ]
  }
}

# variable "security_group_id" {}