#!/bin/bash

echo 'Please run me through burp proxy!'

read -p 'Threads number: ' threads

mkdir nmap exploits sqlrequests

IFS='//' read -ra hostname <<< "$1"

#var declarations

domain="${hostname[2]}"
path=$(pwd)
stamp=$(date +"%m_%d_%Y")


#recon ng dns enumeration start
#create file with workspace.timestamp and start enumerating hosts
touch $domain$stamp.resource
echo ""
echo "workspaces create $domain$stamp" >> $domain$stamp.resource
echo ""
echo "modules load recon/domains-hosts/bing_domain_web" >> $domain$stamp.resource
echo "options set source $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "modules load recon/domains-hosts/google_site_web" >> $domain$stamp.resource
echo "options set source $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "modules load recon/domains-hosts/netcraft" >> $domain$stamp.resource
echo "options set source $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "modules load recon/domains-hosts/brute_hosts" >> $domain$stamp.resource
#echo "options set WORDLIST /root/go/src/amass/examples/wordlists/sorted_knock_dnsrecon_fierce_recon-ng.txt
#" >> $domain$stamp.resource
echo "options set source $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "modules load recon/hosts-hosts/resolve" >> $domain$stamp.resource
echo "options set source default" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "modules load reporting/list" >> $domain$stamp.resource
echo "options set FILENAME $path/$domain$stamp.lst" >> $domain$stamp.resource
echo "options set COLUMN host" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "exit" >> $domain$stamp.resource
echo ""

recon-ng -r $path/$domain$stamp.resource &> /dev/null

#End of recon-ng, see workplace.timestamp for details

if [ "${hostname[0]}" == "https:" ]
then
	port='443'	
elif [ ${hostname[0]} == 'http:' ]
then
	port='80'
fi

if [ $port == 443 ] || [ $port == 80 ]

then

	nmap --script vuln -sV $domain -oA nmap/vuln_web_ports  -p $port

fi

echo "Running full tcp nmap:"

nmap -p- $domain -sV -sC --open --script vuln --reason -oA nmap/full_nmap

searchsploit --nmap /nmap/full_nmap.xml

wafw00f $1

sslscan $1

cmsmap -s $1

bfac -u $1

nikto -Display 1234EP -o nikto.html -Format htm -Tuning 123bde -host $1 -C all

gobuster dir -u $1 -w /root/Documents/Attacks/GoBusterWordlists/dirb/mini.txt -o gobuster_all.result -t $threads --wildcard

'
