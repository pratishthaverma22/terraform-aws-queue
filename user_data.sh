#!/bin/bash

yum update -y
echo "****************script starts here ******************"
sudo hostnamectl set-hostname master
sudo systemctl restart network
export PRIVATE_IP=$(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)
echo "$PRIVATE_IP master">/etc/hosts
sudo yum update -y
sudo amazon-linux-extras install epel -y
curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | sudo bash
curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | sudo bash
sudo yum install rabbitmq-server erlang -y
sudo systemctl enable --now rabbitmq-server.service
sudo truncate -s 0 /var/lib/rabbitmq/.erlang.cookie
echo "XAIFUIBJAVHSEZOKOMHD" >> /var/lib/rabbitmq/.erlang.cookie
sudo systemctl restart rabbitmq-server.service
export USERNAME="$(aws ssm get-parameter --name /${environment_name}/rabbit/USERNAME --with-decryption --output text --query Parameter.Value --region ${region})"
export PASS="$(aws ssm get-parameter --name /${environment_name}/rabbit/PASSWORD --with-decryption --output text --query Parameter.Value --region ${region})"
sudo rabbitmqctl add_user "$USERNAME" "$PASS"
sudo rabbitmqctl set_user_tags admin administrator
sudo rabbitmqctl set_permissions -p / admin ".*" ".*" ".*"
sleep 10s
sudo rabbitmq-plugins enable rabbitmq_management
sudo systemctl restart rabbitmq-server.service

