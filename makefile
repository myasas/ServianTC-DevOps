# @author: Yasas De Silva <myasas@gmail.com>
# @purpose: Streamline the usage of Terraform to avoid having to run
#		    multiple Terraform commands inside multiple directories.

# export AWS_DEFAULT_REGION=ap-southeast-2
# export AWS_PROFILE=default
# export ENVIRONMENT=preprod

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))
TF_DIR := $(ROOT_DIR)/terraform/infrastructure

assert_env:
ifndef ENVIRONMENT
	@echo "Environment value must be provided using |export ENVIRONMENT=" && exit 1
endif

assert_aws_region:
ifndef AWS_DEFAULT_REGION
	@echo "Environment value must be provided using |export AWS_DEFAULT_REGION=" && exit 1
endif

assert_aws_aki:
ifndef AWS_ACCESS_KEY_ID
	@echo "Environment value must be provided using |export AWS_ACCESS_KEY_ID=" && exit 1
endif

assert_aws_sak:
ifndef AWS_SECRET_ACCESS_KEY
	@echo "Environment value must be provided using |export AWS_SECRET_ACCESS_KEY=" && exit 1
endif

assert_aws: assert_aws_region assert_aws_aki assert_aws_sak

assert_all: assert_env assert_aws

hello:
	@echo "Test Method. TF_DIR: $(TF_DIR)"
	
clean:
	@echo "Cleaning terraform workspace..."
	@cd "$(TF_DIR)" && rm -rf .terraform

init: assert_all
	@echo "Initializin Terraform with S3 backend..."
	@cd "$(TF_DIR)" && terraform get -update=true
	@cd "$(TF_DIR)" && terraform init -backend=true -backend-config=../envs/${ENVIRONMENT}/backend.conf

single_try: assert_all
	@echo "Running single TF module only..."
	cd "$(TF_DIR)" && terraform plan -target module.bastion -var-file="../envs/${ENVIRONMENT}/default.tfvars" -out=.terraform/terraform.tfplan -destroy
	cd "$(TF_DIR)" && terraform apply .terraform/terraform.tfplan

deploy: assert_all
	@echo "Building infrastructure and Deploying App on it..."
	@cd "$(TF_DIR)" && terraform plan -var-file="../envs/${ENVIRONMENT}/default.tfvars" -out=.terraform/terraform.tfplan
	@cd "$(TF_DIR)" && terraform apply .terraform/terraform.tfplan

destroy: assert_all
	@echo "Destroying all infrastructure..."
	@cd "$(TF_DIR)" && terraform destroy -var-file="../envs/${ENVIRONMENT}/default.tfvars"
