YABSS
=====

YABSS - Yet Another Bash Script Set.

The script doesn't provide that many features yet but you might find them useful anyway.

* ```lines <file>``` => Get the amount of lines in a file
* ```sudo arping <network address>``` => Ping your neighbour hosts using ARP requests (to bypass some firewalls). Be aware that you can't exit the execution once it runs. The network address must be the first three sections of an IPv4 address. Example: 192.168.178
* ```hostupdate <host> <ip>``` => Updates the IP of the given host in /etc/hosts
* ```homehosthupdate``` => Updates the IP of your homeserver. It reads the environment variables HOME_HOST and HOME_IP_PROVIDER. The latter must be an URL where the IP can be fetched from a text or html file. 
