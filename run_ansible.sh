#!/bin/bash

sudo yum -y install ansible

ansible-playbook /vagrant/main.yml
