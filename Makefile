
packer-init:
	packer init .

packer-validate:
	packer fmt .

packer-build:
	packer build aws-ubuntu.pkr.hcl

packer-build-ask:
	packer build -on-error=ask aws-ubuntu.pkr.hcl

packer-build-debug:
	PACKER_LOG=1 packer build -on-error=ask -debug aws-ubuntu.pkr.hcl
