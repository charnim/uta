#!/bin/bash

echo 'Please run me through burp proxy!'

read -p 'Threads number: ' threads

mkdir nmap exploits sqlrequests

IFS='//' read -ra hostname <<< "$1"


if [ "${hostname[0]}" == "https:" ]
then
	port='443'	
elif [ ${hostname[0]} == 'http:' ]
then
	port='80'
fi

if [ $port == 443 ] || [ $port == 80 ]

then

	nmap --script vuln -sV ${hostname[2]} -oA nmap/vuln_web_ports  -p $port

fi

echo "Running full tcp nmap:"

nmap -p- ${hostname[2]} -sV -sC --open --reason -oA nmap/full_nmap

searchsploit --nmap /nmap/full_nmap.xml

wafw00f $1

sslscan --show-certificate $1

cmsmap -s $1

bfac -u $1

nikto -Display 1234EP -o nikto.html -Format htm -Tuning 123bde -host $1 -C all

gobuster dir -u $1 -w /root/Documents/Attacks/GoBusterWordlists/dirb/mini.txt -o gobuster_all.result -t $threads --wildcard

'
