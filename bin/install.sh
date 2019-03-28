#!/bin/bash

TERRAFORM_VERSION=0.11.13
BIN_DIR=/home/ec2-user/.local/bin
mkdir -p ${BIN_DIR}

mkdir tmp
cd tmp

wget https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip
unzip terraform_${TERRAFORM_VERSION}_linux_amd64.zip



# crete bin dir
mkdir -p ${HOME}/bin
mv terraform ${BIN_DIR}

cd ..
rm -rf tmp

echo Terraform $(terraform --version) is installed
