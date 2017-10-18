#!/bin/bash
yum -y update
yum install -y git
pip install ansible
export PATH=$PATH:/usr/local/bin
export ANSIBLE_PULL="ansible-pull -U https://github.com/skyportal/deploy \
                     --extra-vars=\"variable_host=localhost\" -i \"localhost,\""
$ANSIBLE_PULL playbooks/install-deps.yaml
$ANSIBLE_PULL playbooks/deploy-app.yaml
