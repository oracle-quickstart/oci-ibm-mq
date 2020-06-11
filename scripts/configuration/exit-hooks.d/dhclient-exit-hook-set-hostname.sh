#!/bin/bash
#set -x

OPC_CONF="/etc/oci-hostname.conf"
TMP_DIR=/tmp

echo "set hostname begin `date`: $reason" >> $log_file

# import the oci-hostname configuration info
if [ -f $OPC_CONF ]; then
	. $OPC_CONF
fi

function retry_command() {

  retry_attempts=30
  retry_interval_sec=2
  while [ "$retry_attempts" -gt 0 ]; do

    command_success=true
    $@ || { command_success=false; }
    if [ "$command_success" == false ]; then
      (( retry_attempts-- ))
      echo "Error occurred running command $@. Will retry in $retry_interval_sec seconds"
      sleep $retry_interval_sec
    else
      echo "Successfully executed the command $@" >> $log_file
      break
    fi
  done

  # Check if issue running command still existed after all retry_attempts
  if [ "$command_success" == false ]; then
    echo "ERROR: failed to execute command '$@' (Retried $retry_attempts times)" >> $log_file
    return 1
  fi
}

#Usage: add_entries <file name> <keyword> <an array of the corresponding values for the keyword>
#We pass array by name so if the array name is 'arr', pass it as 'arr' instead of $arr
#This function can be used to add entries to files with a mapping format.
#For example, /etc/hosts has <ip> mapped to <fqdn/host alias>
#The function checks to see if a line containing the given 'keyword' is in the file
#If so, we check the given array of values against the existing values for the keyword in that line.
#Append the values specified in the array to the line if it doesn't already exist.
#If the file does not contain a line with the given keyword,
#the function will add a new line with the given keyword mapped to all values in the given array.
function add_entries() {
    local file=${1}
    local keyword=${2}
    local values=$3[@]
    values=("${!values}")
    if ! grep -w "^$keyword" $file; then
        echo "Line with '$keyword' not found in $file" >> $log_file
        new_entry="$keyword"
        for value in "${values[@]}"
        do
            new_entry="$new_entry $value"
        done
        echo "Adding '$new_entry' to $file" >> $log_file
        echo "$new_entry" >>  $file

    else
        echo "Found line with '$keyword'" >> $log_file
        target_line=$(grep -w "^$keyword" $file)
        for value in "${values[@]}"
        do
            #First case needs spaces around $value to make sure it's not the prefix or suffix of another value
            #Second case checks if $value is at the end of the line
            if [[ $target_line == *" $value "* ]] || [[ $target_line == *" $value" ]]; then
                echo "'$value' already exists in line" >> $log_file
            else
                echo "Adding '$value' to line" >> $log_file
                sed -ie "s/^\<$keyword\>.*$/& $value/g" $file
            fi
        done
    fi
}


# This function updates the hostname 
# Arguments: 
#   Arg1 --  OS version information to set hostname accordingly
#   Arg2 --  Hostname that needs to be set
function update_hostname()
{
    local os_version=${1}
    local new_host_name=${2}

    echo "Updating hostname" >> $log_file

    # 1. run hostname command
    if [ $os_version == 6 ]; then
        # use short hostname for /etc/sysconfig/network
        # https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_Linux/6/html/Installation_Guide/sn-Netconfig-x86.html
        new_host_name_config="HOSTNAME=$new_host_name"
        echo "Update /etc/sysconfig/network with new host name $new_host_name_config" >> $log_file

        if grep --quiet '^HOSTNAME=' /etc/sysconfig/network; then
            echo "HOSTNAME exists in /etc/sysconfig/network. Updating its value" >> $log_file
            sed -i "s/^HOSTNAME=.*$/$new_host_name_config/g"  /etc/sysconfig/network
        else
            echo "Adding HOSTNAME to /etc/sysconfig/network" >> $log_file
            echo "$new_host_name_config" >> /etc/sysconfig/network
        fi

        echo "Running hostname command: hostname $new_host_name" >> $log_file
        hostname $new_host_name

    elif [ $os_version == 7 ]; then
        echo "Running hostnamectl command: hostnamectl set-hostname $new_host_name" >> $log_file
        hostnamectl set-hostname $new_host_name

    fi
}


# This function updates /etc/hosts and /etc/resolv.conf
# Arguments:
#   Arg1 -- new IP address
#   Arg2 -- new hostname of the system
function update_hosts_resolv()
{
    local new_ip_address=${1}
    local new_host_name=${2}

    # Remove old entry from /etc/hosts so that we avoid getting
    # stale information from ipcalc
    sed -i "/^\<$new_ip_address\>.*$/d" /etc/hosts

    # Get fqdn
    fqdn=`ipcalc -h $new_ip_address`
    ipcalc_success=$?
    if [ $ipcalc_success -ne 0 ]; then
        echo "WARNING: ipcalc unsuccessful. This usually happens when there is no DNS."
    else

        # ipcalc returns HOSTNAME=xxxx, need to remove "HOSTNAME="
        fqdn=${fqdn#HOSTNAME=}

        # get subnet_domain_name
        subnet_domain_name=${fqdn#$new_host_name.}

        # verify that the subnet domain is valid, we expect it is of the 
        # form <subnet-name>.<vcn-name>.<oraclevcn>.<com>
        if [[ $subnet_domain_name != *.*.*.* ]]; then
            echo "WARNING: invalid subnet domain name '$subnet_domain_name'."  \
                 "This can happen when there is no DNS." >> $log_file
        else
            # get vcn domain name - everything after the first dot in the subnet domain name
            vcn_domain_name=${subnet_domain_name#*.}
            echo "fqdn=$fqdn" >> $log_file
            echo "subnet_domain_name=$subnet_domain_name" >> $log_file
            echo "vcn_domain_name=$vcn_domain_name" >> $log_file

            # 2. Update /etc/hosts if needed
            new_host_values=("$fqdn" "$new_host_name")
            # Pass array by name
            add_entries "/etc/hosts" "$new_ip_address" new_host_values

            # 3. Update /etc/resolv.conf
            # This is a temp fix till we have a resolution for a proper dhcp response
            new_search_domains=("$subnet_domain_name" "$vcn_domain_name")
            add_entries "/etc/resolv.conf" "search" new_search_domains
        fi
    fi
}

# This fucntion adds NM_CONTROLLED=no entry to the primary interface config file 
# So that network manger does not take cotrol when installed.
# Arguments:
# Arg1 -- primary_ip

function disable_NMcontrol()
{
    local primary_ip=${1}

    # find the primary interface
    primary_if=`ifconfig | grep -B1 $primary_ip | head -n1 | awk -F '[: ]' '{print $1}'`

    # generate the primary interface's ifconfig filepath.
    cfg_file="/etc/sysconfig/network-scripts/ifcfg-${primary_if}"

    # check if the file is present.
    if [ ! -f $cfg_file ]; then
        echo "$cfg_file not found, skip NM_CONTROLLED setting." >> $log_file
        return
    fi

    # check if the keyword is present or not
    if ! grep -w "^NM_CONTROLLED" $cfg_file; then
            # append the line..
            echo "NM_CONTROLLED=no" >> $cfg_file
    else
           # modify the line
           sed -i "s/^\<NM_CONTROLLED\>.*$/NM_CONTROLLED=no/g" $cfg_file
    fi
}

# Get the primary vnic ip.
retry_command curl 169.254.169.254/opc/v1/vnics/ -s  | jq -r '.[0] | .privateIp' > ${TMP_DIR}/thisip.new
primary_ip=$(cat ${TMP_DIR}/thisip.new)
rm ${TMP_DIR}/thisip.new

# This script is invoked whenever dhclient is run.
# We want to skip hostname update if $new_ip_address != $primary_ip 
# so we don't run this for all interfaces
if [ -z "$primary_ip" ]; then
    echo "Skip updating hostname because primary ip is empty." >> $log_file
elif [ "$new_ip_address" != "$primary_ip" ];then
    echo "Skip updating hostname because this was not invoked for the primary vnic" >> $log_file
else
    # add NM_Controlled="no" to primary network interface configuration file 
    disable_NMcontrol $primary_ip

    if [[ $PRESERVE_HOSTINFO -eq 2 ]]; then
        echo "Skip updating hostname, /etc/hosts and /etc/resolv.conf " \
            "as per PRESERVE_HOSTINFO=${PRESERVE_HOSTINFO} setting" >> $log_file
        return 0
    fi

    # reason why this hook was invoked. It is set by dhclient script
    echo "reason=$reason" >> $log_file

    # https://linux.die.net/man/8/dhclient-script
    if [ "$reason" = "BOUND" ] || [ "$reason" = "RENEW" ] || [ "$reason" = "REBIND" ] || [ "$reason" = "REBOOT" ]; then

        kernel_version=$(uname -mrs)
        os_version=0
        if [[ "$kernel_version" == *"el7"* ]]; then
            os_version=7
        elif [[ "$kernel_version" == *"el6"* ]]; then
            os_version=6
        fi

        if [ $os_version == 0 ]; then
            echo "ERROR: Cannot parse version from $kernel_version correctly" >> $log_file
            exit_status=1
        else
            echo "os version = $os_version" >> $log_file
            #These variables are set by dhclient script
            echo new_ip_address=$new_ip_address >> $log_file
            echo new_host_name=$new_host_name >> $log_file
            echo new_domain_name=$new_domain_name >> $log_file

            #Retrieve hostname from metadata if its empty
            if [ -z $new_host_name ]; then
                retry_command curl -s 169.254.169.254/openstack/latest/meta_data.json  | jq '.hostname' -r > ${TMP_DIR}/hostname.new
                new_host_name=$(cat ${TMP_DIR}/hostname.new)
                rm ${TMP_DIR}/hostname.new
            fi

            if [ -z $new_host_name ]; then
                echo "ERROR: new_host_name is empty after retrieving it from metadata json. Exiting." >> $log_file
                exit_status=1
            else
                if [[ $PRESERVE_HOSTINFO -eq 0 ]]; then
                    # update the hostname with new hostname
                    update_hostname $os_version $new_host_name
                elif [[ $PRESERVE_HOSTINFO -eq 1 ]]; then
                    echo "Skip updating hostname as per "   \
                        "PRESERVE_HOSTINFO=${PRESERVE_HOSTINFO} setting" >> $log_file
                fi
                # update hosts and resolv conf files
                update_hosts_resolv $new_ip_address $new_host_name
            fi
        fi
    else
       echo "Not updating because reason=$reason" >> $log_file
    fi
    echo "sethostname END" >> $log_file
fi
