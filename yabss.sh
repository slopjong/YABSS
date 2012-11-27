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

xor(){
    if [ ${#1} != ${#2} ];
    then
        echo "The length of both passed arguments differ"
    else
        for ((i=1; i <= ${#1}; i++))
        do
            echo -n $(($(echo ${1[$i]})^$(echo ${2[$i]})))
        done
    fi
    
    echo ""
}

# based http://stackoverflow.com/a/11120761/1514866
# TODO: this cannot handle long hex numbers
hex2bin(){
    if [ $# -eq 0 ]
    then
        echo "Argument(s) not supplied "
        echo "Usage: hex2bin hex_number(s)"
    else
        
        while [ $# -ne 0 ]
        do  
            for ((i=1; i <= ${#1}; i++))
            do
                DecNum=`printf "%d" 0x${1[$i]}`
                Binary=
                Number=$DecNum
        
                while [ $DecNum -ne 0 ]
                do
                    Bit=$(expr $DecNum % 2)
                    Binary=$Bit$Binary
                    DecNum=$(expr $DecNum / 2)
                done
                    
                #fill up with leading zeros
                for ((z=0; i <= $((4-${#Binary})); i++))
                do
                    echo -n "0"
                done
                
                echo -n "$Binary"
                
                unset Binary
            done
            
            shift
            # Shifts command line arguments one step.Now $1 holds second argument
            
        done
    fi
}

# [0] http://www.linuxjournal.com/content/return-values-bash-functions
# [1] http://www.cyberciti.biz/faq/bash-for-loop/
# [2] http://linuxcommando.blogspot.de/2008/03/using-sed-to-extract-lines-in-text-file.html
