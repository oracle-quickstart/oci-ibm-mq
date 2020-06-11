#!/bin/bash

yum -y install cloud-init rsync wget bind-utils vim


wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
chmod +x ./jq
cp jq /usr/bin


