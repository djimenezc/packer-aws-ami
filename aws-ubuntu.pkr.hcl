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

variable "region" {
  type    = string
  default = "eu-west-1"
}

locals {
  timestamp  = regex_replace(timestamp(), "[- TZ:]", "")
  name_arm64 = "ubuntu-${var.ubuntu_version}-podman-arm64"
  name_amd64 = "ubuntu-${var.ubuntu_version}-podman-amd64"
}

source "amazon-ebs" "ubuntu-arm64" {
  ami_name              = local.name_arm64
  ami_description       = "Ubuntu ${var.ubuntu_version} arm64 with podman version 4.4.0"
  instance_type         = "t4g.micro"
  region                = var.region
  force_deregister      = true
  force_delete_snapshot = true

  tags = {
    Name          = local.name_arm64
    Version       = local.timestamp
    OS_Version    = "Ubuntu ${var.ubuntu_version}"
    Release       = "Latest"
    Base_AMI_ID   = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Architecture  = "arm64"
  }

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-${var.ubuntu_version}-arm64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"

}

source "amazon-ebs" "ubuntu-amd64" {
  ami_name              = local.name_amd64
  ami_description       = "Ubuntu ${var.ubuntu_version} amd64 with podman version 4.4.0"
  instance_type         = "t3a.medium"
  region                = var.region
  force_deregister      = true
  force_delete_snapshot = true

  tags = {
    Name          = local.name_amd64
    Version       = local.timestamp
    OS_Version    = "Ubuntu ${var.ubuntu_version}"
    Release       = "Latest"
    Base_AMI_ID   = "{{ .SourceAMI }}"
    Base_AMI_Name = "{{ .SourceAMIName }}"
    Architecture  = "amd64"
  }

  source_ami_filter {
    filters = {
      name                = "ubuntu/images/*ubuntu-jammy-${var.ubuntu_version}-amd64-server-*"
      root-device-type    = "ebs"
      virtualization-type = "hvm"
    }
    most_recent = true
    owners      = ["099720109477"]
  }
  ssh_username = "ubuntu"

}

build {
  name    = "podman-build"
  sources = [
    "source.amazon-ebs.ubuntu-arm64",
    "source.amazon-ebs.ubuntu-amd64",
  ]

  provisioner "shell" {
    inline = ["echo This provisioner runs first"]
  }

  provisioner "ansible" {
    playbook_file        = "./ansible/playbook.yml"
    galaxy_file          = "./ansible/requirements.yml"
    galaxy_force_install = true
    extra_arguments      = [
      "-e",
      "ansible_winrm_server_cert_validation=ignore",
      "--scp-extra-args", "'-O'"
    ]
    ansible_env_vars = [
      "ANSIBLE_SSH_ARGS='-o PubkeyAcceptedKeyTypes=+ssh-rsa -o HostkeyAlgorithms=+ssh-rsa'"
    ]
  }
}
