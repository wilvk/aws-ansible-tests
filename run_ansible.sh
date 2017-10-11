#!/bin/bash

sudo yum -y install ansible

ansible-playbook /vagrant/ansible/main.yml
