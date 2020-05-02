#!/usr/bin/bash

#Flags:

#The u: means u will need a value if called
#Example for 4 flags parameters:

orange='\033[93m' 

while getopts hd: option
do
        case "${option}"
                in
                d) domain=${OPTARG};;
		h) echo -e "$orange\nusage: recong-ng-auto -d <domain>"
        esac
done



#recon ng dns enumeration start
#create file with workspace.timestamp and start enumerating hosts

path=$(pwd)
stamp=$(date +"%m_%d_%Y")

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
echo "modules load recon/domains-contacts/pgp_search" >> $domain$stamp.resource
echo "options set source $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "modules load recon/companies-multi/whois_miner" >> $domain$stamp.resource
echo "options set source $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "modules load recon/domains-contacts/wikileaker" >> $domain$stamp.resource
echo "options set source $domain" >> $domain$stamp.resource
echo "run" >> $domain$stamp.resource
echo ""
echo "modules load recon/companies-contacts/pen" >> $domain$stamp.resource
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

#recon-ng -r $path/$domain$stamp.resource &> /dev/null

recon-ng -r $path/$domain$stamp.resource 

