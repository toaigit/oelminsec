#!/bin/sh
#  sudo yum -y update
sudo yum -y install bind-utils ntp wget openldap-clients perl git pam_krb5 krb5-workstation nc telnet bzip2 zip mlocate strace unzip

# install python for awscli and then awscli

sudo wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
sudo rpm -Uvh epel-release-latest-7*.rpm
sudo yum -y install python34
sudo curl -O https://bootstrap.pypa.io/get-pip.py
sudo python3 get-pip.py --user
sudo /root/.local/bin/pip install awscli --upgrade --user

#  install shibboleth

sudo curl -o /etc/yum.repos.d/shibboleth.repo http://download.opensuse.org/repositories/security://shibboleth/CentOS_7/security:shibboleth.repo
sudo yum -y install shibboleth

# set the sytem time to PDT

sudo /bin/timedatectl set-timezone America/Los_Angeles

# create user accounts

sudo groupadd -g 3000 tonyvo
sudo useradd -u 3000 -g 3000 -d /home/tonyvo -s /bin/bash -c tonyvo-user tonyvo
sudo echo 'tonyvo ALL=(ALL) NOPASSWD:ALL' | sudo tee -a /etc/sudoers.d/90-cloud-init-users
sudo groupadd -g 44398 duo
sudo usermod -G tonyvo,duo tonyvo
 
#  setup duosecurity repository to install duo
 
sudo cat <<EOF | sudo tee /etc/yum.repos.d/duosecurity.repo
[duosecurity]
name=Duo Security Repository
baseurl=http://pkg.duosecurity.com/CentOS/7/x86_64/$basearch
enabled=1
gpgcheck=1
EOF
sudo rpm --import https://duo.com/RPM-GPG-KEY-DUO
sudo yum -y install duo_unix

#  install ossec

sudo echo 7 | sudo tee /etc/yum/vars/releasever
sudo wget -q -O /tmp/atomic https://updates.atomicorp.com/installers/atomic 
sudo chmod 700 /tmp/atomic
sudo NON_INT=0 /tmp/atomic
sudo yum -y install ossec-hids ossec-hids-client

#  get Stanford Specific Configuration file from s3
sudo mkdir -p /efs/share
sudo /root/.local/bin/aws s3 cp s3://mybucket.stanford.edu/ec2-config.tar.gz /efs/share/ec2config.tar.gz
sudo tar -xzvf /efs/share/ec2config.tar.gz -C /efs/share
sudo /bin/cp /efs/share/etc/krb5.conf /etc/krb5.conf
sudo /bin/cp -p /etc/ssh/sshd_config /etc/ssh/sshd_config.old
sudo /bin/cp /efs/share/etc/ssh/sshd_config /etc/ssh/sshd_config
sudo /bin/cp -p /efs/share/etc/pam.d/sshd /etc/pam.d/sshd
sudo authconfig --enablekrb5 --update
sudo /bin/cp -p /efs/share/etc/pam.d/system-auth-ac /etc/pam.d/system-auth-ac

#  install splunk

sudo yum -y localinstall /efs/share/RPMs/splunkforwarder-6.5.2.rpm

#  clean up

sudo /bin/rm -rf /efs/share/*

#  restart ssh

sudo systemctl restart sshd

#  end of userdata script
