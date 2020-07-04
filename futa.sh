#!/bin/bash

echo 'Please run me through burp proxy!'

read -p 'Threads number: ' threads

mkdir nmap exploits sqlrequests


IFS='//' read -ra hostname <<< "$1"

#var declarations

domain="${hostname[2]}"

echo "Running full tcp nmap:"

nmap -p- $domain -sV -sC --open --script vuln --reason -oA nmap/full_nmap

searchsploit --nmap /nmap/full_nmap.xmli


if [ "${hostname[0]}" == "https:" ]
then
	port='443'	
elif [ ${hostname[0]} == 'http:' ]
then
	port='80'
fi

if [ $port == 443 ] || [ $port == 80 ]

then

	nmap --script vuln -sV $domain -oA nmap/vuln_web_ports$domain  -p $port

fi

wafw00f $1

robocop -u $1 # Runs over disallow entries of the robots.txt of the url(if exists) and opens non 40X/50X urls.

sslscan $1

yawast ssl $1 --tdessessioncount 

cmsmap -s $1

bfac -u $1

nikto -Display 1234EP -o nikto.html -Format htm -Tuning 123bde -host $1 -C all

gobuster dir -u $1 -w /root/Documents/Attacks/GoBusterWordlists/dirb/mini.txt -o gobuster_all.result_$d -t $threads --wildcard

for i in $(cat gobuster_* | awk -F" " '{print $1}' | sort -u); do firefox $1$i; done

