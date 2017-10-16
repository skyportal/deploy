Before launching terraform or ansible, you need to define AWS_ACCESS_KEY_ID
and AWS_SECRET_ACCESS_KEY.

Tag names with dashes are converted to underscores.  I.e., use
`tag_Name_skyportal_asg`, even if `ec2_tag_Name == 'skyportal-asg'`.

SSH into instances:

- Amazon

ssh -i "skyportal-deploy.pem" ec2-user@public-dns-name.amazonaws.com

- Debian

ssh -i skyportal-deploy.pem admin@public-dns-name.amazonaws.com
