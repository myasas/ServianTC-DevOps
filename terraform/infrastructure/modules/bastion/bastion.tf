locals {
  bastion_script = <<USERDATA
#!/bin/bash

set -o xtrace

cat <<EOF > /etc/profile.d/bastion.sh
export PATH=$PATH:/usr/local/bin
EOF

# Instalamos dependencias
yum update -y
yum install -y git jq cifs-utils unzip telnet nc python3-pip python3 python3-setuptools
yum install -y amazon-efs-utils

# Instalamos HELM
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
rm get_helm.sh

# Instalamos KUBECTL
curl -LO https://storage.googleapis.com/kubernetes-release/release/$(curl -s https://storage.googleapis.com/kubernetes-release/release/stable.txt)/bin/linux/amd64/kubectl
chmod +x ./kubectl
mv ./kubectl /usr/local/bin/kubectl

# Instalamos aws-iam-authenticator
curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/aws-iam-authenticator
chmod +x ./aws-iam-authenticator
mv ./aws-iam-authenticator /usr/local/bin/aws-iam-authenticator

# Instalamos eksctl
# curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
# sudo mv /tmp/eksctl /usr/local/bin

# Change port
sed -i 's/#Port 22/Port ${var.bastion_allowed_port}/g' /etc/ssh/sshd_config
systemctl restart sshd

USERDATA

}

data "aws_ami" "my_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_launch_configuration" "bastion_launch" {
  name_prefix = "${var.short_name}-bastion"
  # iam_instance_profile = aws_iam_instance_profile.bastion_instance_profile.name

  image_id      = data.aws_ami.my_ami.id
  instance_type = "t3.micro"

  associate_public_ip_address = true
  security_groups             = [var.security_group_bastion_id]

  user_data_base64 = base64encode(local.bastion_script)

  key_name = aws_key_pair.my_key_pair_bastion.key_name

  root_block_device {
    volume_type           = "gp2"
    volume_size           = "20"
    delete_on_termination = "true"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "bastion_auto" {
  name = "${var.short_name}-bastion"

  launch_configuration = aws_launch_configuration.bastion_launch.id

  desired_capacity = 1
  max_size         = 1
  min_size         = 1

  vpc_zone_identifier = var.vpc_subnet_public_ids

  tag {
    key                 = "Name"
    value               = "${var.short_name}-bastion"
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.default_tags
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }
}
