packer {
  required_plugins {
    amazon = {
      version = ">= 0.0.2"
      source  = "github.com/hashicorp/amazon"
    }
  }
}

variable "ubuntu_version" {
  type    = string
  default = "22.04"
}

variable "arch" {
  type    = string
  default = "arm64"
}

variable "instance_type" {
  type    = string
  default = "t4g.micro"
}

variable "region" {
  type    = string
  default = "eu-west-1"
}

locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
  name      = "ubuntu-${var.ubuntu_version}-podman-${var.arch}"
}

source "amazon-ebs" "ubuntu" {
  ami_name         = local.name
  ami_description  = "Ubuntu ${var.ubuntu_version} ${var.arch} with podman version 4.2.0"
  instance_type    = var.instance_type
  region           = var.region
  force_deregister = true
  force_delete_snapshot = true

  tags = {
    Name          = local.name
    Version       = local.timestamp
    OS_Version    = "Ubuntu ${var.ubuntu_version}"
    Release       = "Latest"
    Base_AMI_ID   = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Architecture  = var.arch
  }

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-${var.ubuntu_version}-${var.arch}-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"

}

build {
  name = "podman-arm"
  sources = [
    "source.amazon-ebs.ubuntu"
  ]

  provisioner "shell" {
    inline = ["echo This provisioner runs first"]
  }
}
