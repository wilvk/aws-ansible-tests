# vagrant-ansible-tests

Vagrant provisioning for running Ansible tests on AWS.

## Overview

This is a Vagrant box that allows the running of Ansible tests in Docker.

## Prerequisites

You must have an AWS account set up with and full administrator access in order to run these tests

## Setup


1. Fork the Ansible repo so you are working with your own copy of the source code.

2. Clone this repo.

3. Copy the default vars file temlpate to the working vars file:

```bash
cp ~/vagrant-ansible-tests/ansible/vars/user_vars.default.yml ~/vagrant-ansible-tests/ansible/vars/user_vars.yml
```

2. Edit the user_vars.yml file and fill in all the variables as required. 

The Github account is the account used to fork the Ansible repo.

The AWS admin account will need full admin access to allow the creation of a test user to run the tests.

You will need the AWS access key id and AWS secret access key for the admin user.

The test user name can be anything and the region used is not greatly important.

3. vagrant up the box

```
vagrant up
```

4. ssh into the box

```
vagrant ssh
```

5. Ansible will be cloned in the vagrant user's home path. You should source the ansible environment variables from this source.

```
source ~/ansible/hacking/env-setup
```

6. You can then run the ansible tests. e.g. to run the ec2_group tests, enter the following:

```
ansible-test integration --docker -v ec2_group
```


