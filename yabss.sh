#!/bin/bash

# Calculate the amount of lines of the passed file.
lines(){
    # echo $(cat -n $1 | egrep -c --regexp="^\s*[[:digit:]]")
    # echo grep -n . $1 # isn't reliable and doesn't return any number if the file is empty
    echo ${$(wc -l $1)/$1}
}

# Ping the neighbour hosts in your network based on arp requests.
# Note: once it runs you can't stop it until it's finished
arpingnet(){
    for i in {1..254}; do arping -c1 $1.$i | grep reply; done
}

# Get the IP of your home server
# Args: $1 => URL where the home server IP should be fetched from
homeip(){
    echo $(curl -s $1 | egrep -m 1 -o '([[:digit:]]{1,3}\.){3}[[:digit:]]{1,3}' | uniq )
}

# this updates a host entry in /etc
hostupdate(){
    local hostfile="/etc/hosts"
    local host=$1
    local ip=$2
    
    if [[ "$ip" == "" ]];
    then
        echo "The IP is empty"
        return
    fi
    
    local lines=$(lines ${hostfile})
    
    if [ "$lines" -eq 0 ] ;
    then
	echo "${ip} ${host}" > ${hostfile}
	return
    fi
    
    # iterate over the lines
    for i in {1..${lines}};
    do
	# get the line content, look if the host is present
	# and update the IP
        sed -n ${i}p ${hostfile} | grep -q -o ${host} && sed -i "${i}s/[0-9].*/${ip} ${host}/g" ${hostfile} 
	# TODO: if the entry with ${host} is missing in the hosts file nothing happens and it also won't be added
    done
}

# Updates the host entry for the home server
homehostupdate(){
    local ip=$(homeip $HOME_IP_PROVIDER)
    
    if [[ "$ip" == "" ]];
    then
        echo "The IP is empty"
        return
    fi
    
    hostupdate $HOME_HOST $ip
}

# [0] http://www.linuxjournal.com/content/return-values-bash-functions
# [1] http://www.cyberciti.biz/faq/bash-for-loop/
# [2] http://linuxcommando.blogspot.de/2008/03/using-sed-to-extract-lines-in-text-file.html
