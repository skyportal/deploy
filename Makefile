plan:
	terraform plan

apply:
	terraform apply

ansible-prepare:
	pip install boto ansible
	wget -O ./ansible-ec2/ec2.py https://raw.githubusercontent.com/ansible/ansible/devel/contrib/inventory/ec2.py
	chmod +x ./ansible-ec2/ec2.py

instance-list-refresh:
	@./ansible-ec2/ec2.py --refresh

instance-list:
	@./ansible-ec2/ec2.py --list | grep public_dns | cut -d '"' -f 4

ping:
	@ansible-playbook playbooks/ping.yaml

