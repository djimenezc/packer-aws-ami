
packer-init:
	packer init .

packer-validate:
	packer fmt .

packer-build:
	packer build aws-ubuntu.pkr.hcl

packer-build-debug:
	packer build aws-ubuntu.pkr.hcl -on-error=ask
