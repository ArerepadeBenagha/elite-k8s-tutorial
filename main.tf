#########Local Tags
locals {
  common_tags = {
    Environment = "Dev"
    Department  = "eliteInfra"
    Company     = "elite Solutions"
    Managedwith = "Terraform"
  }
}

#######Key
resource "aws_key_pair" "mykeypair" {
  key_name   = "mykeypair"
  public_key = file(var.path_to_public_key)
  lifecycle {
    ignore_changes = [public_key]
  }
}

####Ec2-instance
resource "aws_instance" "example" {
  ami           = lookup(var.amis, var.aws_region)
  instance_type = var.instance_type
  count         = var.instance_count
  subnet_id     = aws_subnet.main-public-1.id
  key_name      = aws_key_pair.mykeypair.key_name
  vpc_security_group_ids = [aws_security_group.example-instance.id]
  tags = {
    Name        = element(var.instance_tags, count.index)
  }
}
resource "aws_ebs_volume" "volume-new" {
  availability_zone = "${element(aws_instance.example.*.availability_zone, count.index)}"
  count             = "${var.instance_count * var.elite_ebs_volume_count}"
  size              = var.elite_ebs_volume_size
  type              = var.volume_type
}

resource "aws_volume_attachment" "ebs-volume-attachment" {
  count       = "${var.instance_count * var.elite_ebs_volume_count}"
  volume_id   = "${aws_ebs_volume.volume-new.*.id[count.index]}"
  device_name = "${element(var.elite-device-names, count.index)}"
  instance_id = "${element(aws_instance.example.*.id, count.index)}"
}

########Vpc.tf
resource "aws_vpc" "main" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"
  enable_dns_support = "true"
  enable_dns_hostnames = "true"
  enable_classiclink = "false"
  tags = {
    Name = "main"
  }
}

# Subnets
resource "aws_subnet" "main-public-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Main-public-1"
  }
}
resource "aws_subnet" "main-public-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.2.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Main-public-2"
  }
}
resource "aws_subnet" "main-public-3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.3.0/24"
  map_public_ip_on_launch = "true"
  availability_zone = "us-east-1c"

  tags = {
    Name = "Main-public-3"
  }
}
resource "aws_subnet" "main-private-1" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.4.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Main-private-1"
  }
}
resource "aws_subnet" "main-private-2" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.5.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Main-private-2"
  }
}
resource "aws_subnet" "main-private-3" {
  vpc_id     = aws_vpc.main.id
  cidr_block = "10.0.6.0/24"
  map_public_ip_on_launch = "false"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Main-private-3"
  }
}

# Internet GW
resource "aws_internet_gateway" "main-gw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "main"
  }
}

# route tables
resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main-gw.id
  }

  tags = {
    Name = "main-public-1"
  }
}

# route associations public
resource "aws_route_table_association" "main-public-1-a" {
       subnet_id = aws_subnet.main-public-1.id
       route_table_id = aws_route_table.main-public.id
}
resource "aws_route_table_association" "main-public-2-a" {
       subnet_id = aws_subnet.main-public-2.id
       route_table_id = aws_route_table.main-public.id
}
resource "aws_route_table_association" "main-public-3-a" {
       subnet_id = aws_subnet.main-public-3.id
       route_table_id = aws_route_table.main-public.id
}

########eip
resource "aws_eip" "elite-eip" {
  instance = aws_instance.example[count.index].id
  count = 3
  vpc   = true
  tags = {
       Name = element(var.instance_eips, count.index)
  }
}

######eip attachment
resource "aws_eip_association" "eip_assoc" {
  count = 3
  instance_id   = aws_instance.example[count.index].id
  allocation_id = aws_eip.elite-eip[count.index].id
}

########Security Group
resource "aws_security_group" "example-instance" {
  vpc_id      = aws_vpc.main.id
  name        = "allow-ssh"
  description = "security group that allows ssh and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port   = ingress.key
      to_port     = ingress.key
      cidr_blocks = ingress.value
      protocol    = "tcp"
    }
  }
}


#######s3 bucket
resource "aws_s3_bucket" "terraform-state" {
  bucket = "terraform-state-00gc"
  acl    = "private"
  versioning {
    enabled = true
  }
tags = local.common_tags
}