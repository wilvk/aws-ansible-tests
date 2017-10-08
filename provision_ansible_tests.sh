#!/bin/bash

set -x

#please set your custom variables here:
#please enter your github account alias:
GITHUB_ACCOUNT=
#please enter your AWS admin user name:
ADMIN_USER=
#please enter your admin AWS access key id:
ADMIN_ACCESS_KEY=
#please enter your admin AWS secret access key:
ADMIN_SECRET_ACCESS_KEY=
#please enter your AWS ansible testing account (e.g. ansible_test):
ANSIBLE_TEST_ACCOUNT=ansible_test
#please enter your AWS region (eg. us-west-1):
AWS_TEST_REGION=ap-southeast-2

#path credentials
AWS_PATH=~/.aws
AWS_CREDENTIALS_FILE="${AWS_PATH}/credentials"

echo "Removing any existing credentials"
rm -rf $AWS_PATH
mkdir $AWS_PATH
touch "${AWS_CREDENTIALS_FILE}"

echo "Setting AWS variables and credentials"

export ADMIN_PROFILE=$ADMIN_USER
echo "export ADMIN_PROFILE=$ADMIN_USER" >> ~/.bash_profile

echo "[${ADMIN_USER}]" >> $AWS_CREDENTIALS_FILE
echo "aws_access_key_id=${ADMIN_ACCESS_KEY}" >> $AWS_CREDENTIALS_FILE
echo "aws_secret_access_key=${ADMIN_SECRET_ACCESS_KEY}" >> $AWS_CREDENTIALS_FILE
echo "aws_region=${AWS_TEST_REGION}" >> $AWS_CREDENTIALS_FILE

echo "Installing Ansible and Git"

sudo yum -y install ansible
sudo yum -y install git

echo "Cloning Ansible repo for user ${GITHUB_ACCOUNT}"
cd ~
git clone https://github.com/${GITHUB_ACCOUNT}/ansible
cd ~/ansible
git remote add upstream https://github.com/ansible/ansible
git pull upstream devel

echo "Installing and configuring Docker"
sudo yum -y install docker
sudo groupadd docker
sudo gpasswd -a $USER docker
sudo systemctl restart docker
newgrp docker

echo "Installing AWS dependencies"
pip install --user botocore boto3 boto awscli

echo "Creating Ansible Test User and group with AdministratorAccess for: ${ANSIBLE_TEST_ACCOUNT}"
aws iam delete-user --user-name ${ANSIBLE_TEST_ACCOUNT} --profile ${ADMIN_PROFILE}
aws iam delete-group --group-name ${ANSIBLE_TEST_ACCOUNT} --profile ${ADMIN_PROFILE}
aws iam create-user --user-name ${ANSIBLE_TEST_ACCOUNT} --profile ${ADMIN_PROFILE}
aws iam create-group --group-name ${ANSIBLE_TEST_ACCOUNT} --profile ${ADMIN_PROFILE}
aws iam attach-group-policy --group-name ${ANSIBLE_TEST_ACCOUNT} --policy-arn arn:aws:iam::aws:policy/AdministratorAccess --profile ${ADMIN_PROFILE}
aws iam add-user-to-group --user-name ${ANSIBLE_TEST_ACCOUNT} --group_name ${ANSIBLE_TEST_ACCOUNT} --profile ${ADMIN_PROFILE}
aws iam create-access-key --user-name ${ANSIBLE_TEST_ACCOUNT} --profile ${ADMIN_PROFILE} --output text

# capture output from create-access-key and add to credentials then use in sts_output for session token

#echo "Creating Ansible Cloud Config file from template"

#cp ~/ansible/test/integration/cloud-config-aws.yml.template ~/ansible/test/integration/cloud-config-aws.yml

echo "Setting Ansible Test User Environment Variables"
STS_OUTPUT="$(aws sts get-session-token --profile=$ADMIN_PROFILE --output=text)"

ACCESS_KEY=`echo $STS_OUTPUT|awk '{print $2}'`
SECRET_ACCESS_KEY=`echo $STS_OUTPUT|awk '{print $4}'`
SECURITY_TOKEN=`echo $STS_OUTPUT|awk '{print $5}'`

export AWS_ACCESS_KEY_ID="${ACCESS_KEY}"
export AWS_SECRET_ACCESS_KEY="${SECRET_ACCESS_KEY}"
export AWS_SESSION_TOKEN="${SECURITY_TOKEN}"

echo "export AWS_ACCESS_KEY_ID='${ACCESS_KEY}'" >> ~/.bash_profile
echo "export AWS_SECRET_ACCESS_KEY='${SECRET_ACCESS_KEY}'" >> ~/.bash_profile
echo "export AWS_SESSION_TOKEN='${SECURITY_TOKEN}'" >> ~/.bash_profile

echo "Configuring Ansible for test user ${ANSIBLE_TEST_ACCOUNT}"
ansible-playbook ~/ansible/hacking/aws_config/setup-iam.yml -e iam_group=${ANSIBLE_TEST_ACCOUNT} -e profile=${ADMIN_PROFILE} -e region=${AWS_TEST_REGION} -vv

echo "Checking Admin User ${ADMIN_USER} is set correctly:"
aws sts get-caller-identity --profile=${ADMIN_PROFILE}

echo "Setting Ansible hacking environment variables"
source ~/ansible/hacking/env-setup
echo "echo 'before running Ansible Tests, run: source ~/ansible/hacking/env-setup'" >> ~/.bash_profile

echo "Checking Ansible Test User ${ANSIBLE_TEST_ACCOUNT} is set correctly: "
ansible -m shell -a 'aws sts get-caller-identity' -e @~/ansible/test/integration/cloud-config-aws.yml localhost

#echo "Running basic ec2_group Ansible Tests to confirm all is working"
#ansible-test intgration --docker -v ec2_group
