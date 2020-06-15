#!/bin/bash

## Preconfigure


#Setup sshless login https://linuxize.com/post/how-to-setup-passwordless-ssh-login/

ssh-copy-id -i ~/.ssh/oci opc@150.136.68.21
ssh opc@150.136.68.21
sudo -i
  iFhCVrn!1020
$> passwd -d root

## Modify /etc/ssh/sshd_config
PasswordAuthentication no


#$> cd ~
#$> curl -O https://objectstorage.us-phoenix-1.oraclecloud.com/p/qnGdEeuts2qRSn4EwOfEb9cys9fYRmyGn6EDsmsg_2I/n/imagegen/b/agents/o/oracle-cloud-agent-0.0.18-18.el7.x86_64.rpm -v
#$> sudo yum install -y oracle-cloud-agent-0.0.18-18.el7.x86_64.rpm
#$> Rm oracle-cloud-agent-0.0.18-18.el7.x86_64.rpm


subscription-manager repos --disable=rhel-7-server-rt-beta-rpms
systemctl disable NetworkManager



yum -y install cloud-init wget rsync bind-utils vim
## https://www.cyberciti.biz/faq/installing-rhel-epel-repo-on-centos-redhat-7-x/
cd /tmp
wget https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
yum install epel-release-latest-7.noarch.rpm


## 7.7
cd /etc/cloud/cloud.d
wget https://github.com/oracle-quickstart/oci-ibm-mq/blob/master/scripts/configuration/cloud.cfg.d_7.7.tar.gz?raw=true
tar -xzvf cloud.cfg.d_7.7.tar.gz
rm cloud.cfg.d_7.7.tar.gz 


cd /etc/dhcp/
wget https://github.com/oracle-quickstart/oci-ibm-mq/raw/master/scripts/configuration/dhcp_7.7.tar.gz
tar -xzvf dhcp_7.7.tar.gz
rm dhcp_7.7.tar.gz 


cd /etc/
wget https://raw.githubusercontent.com/oracle-quickstart/oci-ibm-mq/master/scripts/configuration/oci-hostname.conf






copy over ssh.d/cloud-init file
copy over /etc/oci-hostname.conf



# 7.8 Only
# vim /etc/sysconfig/network-scripts/ifcfg-ens3
NM_CONTROLLED=no








# 7.8 Only
# /etc/cloud/cloud.cfg
network:
  config: disabled

7.7 Only



wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x ./jq
mv jq /usr/bin


wget https://raw.githubusercontent.com/oracle-quickstart/oci-ibm-mq/master/scripts/configuration/oci-hostname.conf
mv oci-hostname.conf /etc/

wget https://raw.githubusercontent.com/oracle-quickstart/oci-ibm-mq/master/scripts/configuration/dhclient-exit-hooks
mv dhclient-exit-hooks /etc/dhcp/
chmod 755 /etc/dhcp/dhclient-exit-hooks

wget https://raw.githubusercontent.com/oracle-quickstart/oci-ibm-mq/master/scripts/configuration/exit-hooks.d/dhclient-exit-hook-set-hostname.sh
 mkdir /etc/dhcp/exit-hooks.d
mv dhclient-exit-hook-set-hostname.sh /etc/dhcp/exit-hooks.d/
chmod 755 /etc/dhcp/exit-hooks.d/dhclient-exit-hook-set-hostname.sh 







Issues with 7.7
Jun 11 12:27:28 rhel7-8---kernel3-10-0-1062---basicconf dhclient[1174]: /var/lib/dhclient/dhclient-8d2637bf-6205-4946-8902-9da14fd271ca-ens3.lease line 11: expecting numeric value.
Jun 11 12:27:28 rhel7-8---kernel3-10-0-1062---basicconf dhclient[1174]:   option classless-static-routes 0,

lease {
  interface "ens3";
  fixed-address 10.0.0.12;
  option subnet-mask 255.255.255.0;
  option dhcp-lease-time 86400;
  option routers 10.0.0.1;
  option dhcp-message-type 5;
  option domain-name-servers 169.254.169.254;
  option dhcp-server-identifier 169.254.169.254;
  option interface-mtu 9000;
  option domain-name "genericvcn2.oraclevcn.com";
  renew 5 2020/06/12 02:24:05;
  rebind 5 2020/06/12 13:27:16;
  expire 5 2020/06/12 16:27:16;




lease {
  interface "ens3";
  fixed-address 10.0.0.13;
  option subnet-mask 255.255.255.0;
  option routers 10.0.0.1;
  option dhcp-lease-time 86400;
  option dhcp-message-type 5;
  option dhcp-server-identifier 169.254.169.254;
  option domain-name-servers 169.254.169.254;
  option interface-mtu 9000;
  option classless-static-routes 0,10,0,0,1,16,169,254,0,0,0,0;
  option domain-name "genericvcn2.oraclevcn.com";
  renew 5 2020/06/12 01:42:48;
  rebind 5 2020/06/12 13:31:43;
  expire 5 2020/06/12 16:31:43;
}







