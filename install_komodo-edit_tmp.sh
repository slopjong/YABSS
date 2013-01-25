#!/bin/bash

# Installs Komodo-Edit 7.1.3 in /tmp/komodo-edit. This can make sense if you would 
# hit your available quota on a cluster where you cannot install software yourself.

mkdir -p /tmp/komodo-edit
OPWD="$PWD"
cd /tmp/komodo-edit
wget http://downloads.activestate.com/Komodo/releases/7.1.3/Komodo-Edit-7.1.3-11027-linux-x86_64.tar.gz
tar xzvf *.tar*
cd Komodo-Edit-7.1*
./install.sh --install-dir /tmp/komodo-edit -s 2>&1
cd "$OPWD"
