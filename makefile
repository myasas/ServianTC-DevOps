# @author: Yasas De Silva <myasas@gmail.com>
# @purpose: Streamline the usage of Terraform to avoid having to run
#		    multiple Terraform commands inside multiple directories.

# export AWS_DEFAULT_REGION=ap-southeast-2
# export AWS_PROFILE=default
# export ENVIRONMENT=preprod

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
TF_DIR := $(ROOT_DIR)/terraform/infrastructure

hello:
	@echo "Test Method. TF_DIR: $(TF_DIR)"
	
clear:
	@echo "Cleaning terraform workspace"
	@cd "$(TF_DIR)" && rm -rf .terraform

init:
	@echo "Initializin Terraform with S3 backend"
	@cd "$(TF_DIR)" && terraform get -update=true
	@cd "$(TF_DIR)" && terraform init -backend=true -backend-config=../envs/${ENVIRONMENT}/backend.conf

single_try:
	@echo "Running single TF module at once"
	cd "$(TF_DIR)" && terraform plan -target module.bastion -var-file="../envs/${ENVIRONMENT}/default.tfvars" -out=.terraform/terraform.tfplan -destroy
	cd "$(TF_DIR)" && terraform apply .terraform/terraform.tfplan

deploy:
	@echo "Building infrastructure and Deploying App on it"
	@cd "$(TF_DIR)" && terraform plan -var-file="../envs/${ENVIRONMENT}/default.tfvars" -out=.terraform/terraform.tfplan
	@cd "$(TF_DIR)" && terraform apply .terraform/terraform.tfplan

destroy:
	@echo "Destroying all infrastructure"
	@cd "$(TF_DIR)" && terraform destroy -var-file="../envs/${ENVIRONMENT}/default.tfvars"
