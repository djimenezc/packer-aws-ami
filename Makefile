
packer-init:
	packer init .

packer-validate:
	packer fmt .

packer-build:
	packer build aws-ubuntu.pkr.hcl
