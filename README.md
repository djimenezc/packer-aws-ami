# packer-aws-ami
Create a AWS AMI with packer

## First steps:

Init packer
```shell
make packer-init
```

Validate packer files
```shell
make packer-validate
```

Build packer image
```shell
make packer-build
```

> **WARNING**: Before building the AMI, please define AWS credentials variables


## Links: 
- https://learn.hashicorp.com/tutorials/packer/aws-get-started-build-image?in=packer/aws-get-started
