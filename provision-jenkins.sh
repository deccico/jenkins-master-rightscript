#!/bin/bash

# Deploys Jenkins master instance based on a blank ami and a data Jenkins snapshot
#
#
#


set -ex

#get the right volume
export disk=`sudo lsblk --output NAME,TYPE,SIZE,FSTYPE,MOUNTPOINT,LABEL|grep -v /|grep -v xvda|cut -d " " -f 1|grep -v NAME`

#mount the data volume
sudo mkdir /data 
sudo mount /dev/$disk /data

sudo useradd jenkins
sudo mkdir /home/jenkins

#set auto-backups
sudo apt-get install python3-pip -y
sudo pip3 install awscli
sudo mkdir /home/jenkins/.aws
sudo cp /data/jenkins/config/ubuntu/home/jenkins/.aws/* /home/jenkins/.aws/ 
sudo mkdir -p /data/jenkins/config/aws/aws-ec2-ebs-automatic-snapshot-bash/
cd /data/jenkins/config/aws/aws-ec2-ebs-automatic-snapshot-bash/
sudo curl -O https://raw.githubusercontent.com/deccico/aws-ec2-ebs-automatic-snapshot-bash/master/ebs-snapshot.sh
sudo chmod a+x ebs-snapshot.sh
#set up crontab
sudo crontab /data/jenkins/config/ubuntu/cron -u jenkins

#set permissions
sudo chown -R jenkins:jenkins /home/jenkins/
sudo chown -R jenkins:jenkins /data/jenkins/

#installing jenkins
sudo apt-get install daemon default-jre -y
sudo dpkg -i /data/jenkins/config/ubuntu/jenkins_2.7.4_all.deb

#update configuration
sudo cp /data/jenkins/config/ubuntu/etc/rc.local /etc/rc.local
sudo cp /data/jenkins/config/ubuntu/etc/default/jenkins /etc/default/jenkins

#update iptables
sudo /etc/rc.local

#restart jenkins
sudo service jenkins restart