# vagrant-ansible-tests

## Overview

This is a Vagrant box that allows the running of Ansible tests for AWS using Docker.
Tested on Mac OSX.

## Prerequisites

You must have an AWS account set up with and full administrator access in order to run these tests

## Setup


1. Fork the Ansible repo so you are working with your own copy of the source code.

2. Clone this repo.

3. Copy the default vars file template to the working vars file:

```bash
cp ~/vagrant-ansible-tests/ansible/vars/user_vars.default.yml \
  ~/vagrant-ansible-tests/ansible/vars/user_vars.yml
```

2. Edit the user_vars.yml file and fill in all the variables as required. e.g.

```yaml
---
# File:

## please set your custom variables here:

# the username of your github account with a forked version of ansible e.g. wilvk):
github_username: wilvk

# your AWS admin user name (e.g. admin):
aws_admin_user: admin

# your admin AWS access key id:
aws_admin_access_key: AKIAIXXXXXXXXXXXXXXX

# your admin AWS secret access key:
aws_admin_secret_access_key: XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX

# your AWS ansible testing account (e.g. ansible_test):
aws_ansible_test_user: ansible_test

# your AWS region (eg. us-west-1):
aws_test_region: ap-southeast-2
```


The Github account is the account used to fork the Ansible repo.

The AWS admin account will need full admin access to allow the creation of a test user to run the tests.

You will need the AWS access key id and AWS secret access key for the admin user.

The test user name can be anything and the region used is not greatly important.

3. vagrant up the box

```bash
vagrant up
```

4. ssh into the box

```bash
vagrant ssh
```

5. Ansible will be cloned in the vagrant user's home path. You should source the ansible environment variables from here.

```bash
source ~/ansible/hacking/env-setup
```

6. You can then run the ansible tests. 

e.g. to run the ec2_group tests, enter the following:

```bash
ansible-test integration --docker -v ec2_group
```

## TODO:

- Fix user validations - use proper asserts
- Get ec2_group test working in Ansible
