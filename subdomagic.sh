#!/bin/bash

if [ ! -d "/opt/EyeWitness" ] || [-d "/opt/massdns"] || [-d "/opt/subfinder"]; then
  echo "Please run setup.sh"
fi 

# clear terminal (aesthetic!)
clear

# banner (aesthetic!)
cat logo.txt

# prompt user for doamin
echo ""
echo "Enter your target domain (such as \"example.com\") "

read domainName

# prompt user for nmap settings
echo ""
echo "Would you like fast or comprehensive output from the port scan?"
echo "[1] Fast - 8 Common Ports"
echo "[2] Comprehensive - TCP Top 1000"
echo ""

read nmapChoice

echo -e "${YELLOW}[+] Making directory structure..."

# make directory structure
cd ./output

if [ ! -d "$domainName" ]; then
  mkdir $domainName
fi

cd $domainName

echo -e "${YELLOW}[+] Running subodmain enumeration...this may take a while..."

# run amass
amass enum -src -d $domainName -o $domainName-amass.txt

# run subfinder
./subfinder -d $domainName -o $domainName-subfinder.txt

# run massdns
./scripts/subbrute.py lists/names.txt $domainName | ./bin/massdns -r lists/resolvers.txt -t A -o S -w $domainName-massdns.txt

echo -e "${YELLOW}[+] Consolidating subdomain findings..."

# dedup all subdomain findings 
cat $domainName-amass.txt $domainName-subfinder.txt $domainName-massdns.txt > $domainName-subdomains.txt

sort $domainName-subdomains.txt | uniq -u > $domainName-subdomains.txt

echo -e "${YELLOW}[+] Conducting initial scan..."

# run nmap scan for host discovery/web/few common ports
nmap -oA $domainName-nmap-fast --stats-every 60s --log-errors --traceroute --reason --randomize-hosts -v -R -PE -PM -PO -PU -PS80,23,443,21,22,25,3389,110,445,139 -PA80,443,22,445,139 -sS -sV -p21,22,23,25,80,443,8080,8443 $domainName-subdomains.txt

# if statement for choice 1, quick nmap scan
if [ $nmapChoice = "1" ]          
then
    # grep for webservers
    cat $domainName-nmap-fast.gnmap | grep "open[^, ]*\(http\|sip\|ipp\|oem-agent\|soap\|snet-sensor-mgmt\|connect-proxy\|cpq-wbem\|event-port\|analogx\|proxy-plus\|saphostctrl\|saphostctrls\|spss\|sun-answerbook\|wsman\|wsmans\|wso2esb-console\|xmpp-bosh\)" | cut -d" " -f 2 | sort -u > $domainName-webservers.txt
fi 

# if statement for choice 2, nmap tcp top 1000
if [ $nmapChoice = "2" ]             
then
    echo -e "${YELLOW}[+] Conducting comprehensive scan..."
    #grep for online hosts
    grep -i "status: up" $domainName-nmap-fast.gnmap | awk -F" " '{print $2}' > $domainName-online.txt

    #nmap for tcp 1000
    nmap -oA $domainName-comprehensive --stats-every 60s --log-errors --reason --randomize-hosts -v -R -Pn -A -sSVC --top-ports 1000 -iL $domainName-nmap-fast.gnmap

    # grep for webservers
    cat $domainName-comprehensive.gnmap | grep "open[^, ]*\(http\|sip\|ipp\|oem-agent\|soap\|snet-sensor-mgmt\|connect-proxy\|cpq-wbem\|event-port\|analogx\|proxy-plus\|saphostctrl\|saphostctrls\|spss\|sun-answerbook\|wsman\|wsmans\|wso2esb-console\|xmpp-bosh\)" | cut -d" " -f 2 | sort -u > $domainName-webservers.txt
fi 

echo -e "${YELLOW}[+] Screenshotting webservers with EyeWitness..."
# Run EyeWitness
./EyeWitness.py -f $domainName-webservers.txt --web




