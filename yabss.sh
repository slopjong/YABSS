#!/bin/bash

# calculate the amount of lines of the passed file
lines(){
	# wc -l could have been useful too
	echo $(cat -n $1 | egrep -c --regexp="^\s*[[:digit:]]")
}

# ping the neighbour hosts in your network based on arp requests
# Note: once it runs you can't stop it until it's finished
arpingnet(){
	for i in {1..254}; do arping -c1 $1.$i | grep reply; done
}

# [0] http://www.linuxjournal.com/content/return-values-bash-functions
# [1] http://www.cyberciti.biz/faq/bash-for-loop/
