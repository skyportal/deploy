# SkyPortal Deployment

## Accessing AWS

- Sign in to AWS (if you are part of a group, the URL is of the form
  https://012345678901.signin.aws.amazon.com/console)
- Create a key pair named `skyportal-deploy`, and save the `.pem` file
  as `./skyportal-deploy.pem` (if you are working on an existing
  deployment, you need to get the existing key from a teammate).

## IAM configuration

- Navigate to
  https://console.aws.amazon.com/iam/home?region=us-west-1#/home
- Create a group called `deploy` with the following permissions attached:
  - AmazonRDSFullAccess
  - AmazonEC2FullAccess
  - AmazonS3FullAccess
  - CloudWatchFullAccess
  - AmazonDynamoDBFullAccess
  - AmazonRoute53DomainsFullAccess
  - AmazonRoute53FullAccess
- Create a new user called `terraform`, that will be used to handle
  the deployment.  Add this user to the `deploy` group.
- On the `terraform` user page, click on `credentials` and create an
  access key.  Save two important values: the access key ID, and the
  access key value.

## Setting up the environment

Before launching terraform or ansible, define the environment
variables `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to point to
the key ID and value, mentioned above.

## Terraform notes

## Ansible notes

- Launch an Ansible playbook: `ansible-playbook playbooks/ping.yaml`

- Launch on a specific instance:
  ``ansible-playbook --extra-vars="variable_host=tag_Name_skyportal_asg" \
      playbooks/deploy-app.yaml``

- Tag names with dashes are converted to underscores.  I.e., use
  `tag_Name_skyportal_asg`, even if `ec2_tag_Name == 'skyportal-asg'`.

## Debugging instances

- Amazon

`ssh -i "skyportal-deploy.pem" ec2-user@public-dns-name.amazonaws.com`

- Debian

`ssh -i skyportal-deploy.pem admin@public-dns-name.amazonaws.com`

## AWS Notes

- The user data script output is logged to `/var/log/cloud-init-output.log`.
