#!/bin/bash

if [ ! -d "output" ]; then
  exit "Please run \"setup.sh\""
fi 

# clear terminal (aesthetic!)
clear

# banner (aesthetic!)
cat logo.txt

# prompt user for doamin
echo ""
echo -e "\e[1mEnter your target domain (such as \"example.com\"): \e[22m"

read domainName

# prompt user for nmap settings
echo ""
echo -e "\e[1mWould you like fast or comprehensive output from the port scan? \e[22m"
echo ""
echo "[1] Fast - 8 Common Ports, Smaller Subdomain Wordlist"
echo "[2] Comprehensive - TCP Top 1000, Gigantic Wordlist"
echo ""

read nmapChoice

echo ""
echo -e "\e[102m[+] Making directory structure\e[49m"

# make directory structure
cd output

if [ ! -d "$domainName" ]; then
  mkdir $domainName
fi

cd $domainName

echo -e "\e[102m[+] Running subodmain enumeration...this may take a while...\e[49m"

# run amass
amass enum -o $domainName-amass.txt -d $domainName


# run subfinder
cd /opt/subfinder
./subfinder -d $domainName -o /opt/subdomagic/output/$domainName/$domainName-subfinder.txt

# run massdns
cd /opt/massdns/

if [ $nmapChoice ="1"]
then
./scripts/subbrute.py lists/names.txt $domainName |./bin/massdns -r lists/resolvers.txt -t A -o S -w /opt/subdomagic/output/$domainName/$domainName-massdns.txt
fi

if [ $nmapChoice ="2" ]
then
./scripts/subbrute.py lists/all.txt $domainName |./bin/massdns -r lists/resolvers.txt -t A -o S -w /opt/subdomagic/output/$domainName/$domainName-massdns.txt
fi


echo -e "\e[102m[+] Consolidating subdomain findings...\e[49m"

cd /opt/subdomagic/output/$domainName

# dedup all subdomain findings 

mv /var/lib/snapd/void/$domainName-amass.txt /opt/subdomagic/output/$domainName

cat $domainName-massdns.txt | awk '{print $1}' 

cat $domainName-amass.txt $domainName-subfinder.txt $domainName-massdns.txt > $domainName-combinedSubdomains.txt

sort $domainName-combinedSubdomains.txt | uniq -u > $domainName-subdomains.txt

rm $domainName-combinedSubdomains.txt

echo -e "\e[102m[+] Conducting initial scan...\e[49m"

cd /opt/subdomagic/output/$domainName
mkdir nmap_scans
cd nmap_scans

# run nmap scan for host discovery/web/few common ports
nmap -oA $domainName-nmap-fast --stats-every 60s --log-errors --traceroute --reason --randomize-hosts -v -R -PE -PM -PO -PU -PS80,23,443,21,22,25,3389,110,445,139 -PA80,443,22,445,139 -sS -sV -p21,22,23,25,80,443,8080,8443 -iL ../$domainName-subdomains.txt

# if statement for choice 1, quick nmap scan
if [ $nmapChoice = "1" ]          
then
    # grep for webservers
    cat $domainName-nmap-fast.gnmap | grep "open[^, ]*\(http\|sip\|ipp\|oem-agent\|soap\|snet-sensor-mgmt\|connect-proxy\|cpq-wbem\|event-port\|analogx\|proxy-plus\|saphostctrl\|saphostctrls\|spss\|sun-answerbook\|wsman\|wsmans\|wso2esb-console\|xmpp-bosh\)" | cut -d" " -f 2 | sort -u > ../$domainName-webservers.txt
fi 

# if statement for choice 2, nmap tcp top 1000
if [ $nmapChoice = "2" ]             
then
    echo -e "\e[102m[+] Conducting comprehensive scan...\e[49m"
    #grep for online hosts
    grep -i "status: up" $domainName-nmap-fast.gnmap | awk -F" " '{print $2}' > $domainName-online.txt

    #nmap for tcp 1000
    nmap -oA $domainName-comprehensive --stats-every 60s --log-errors --reason --randomize-hosts -v -R -Pn -A -sSVC --top-ports 1000 -iL ../$domainName-online.txt

    # grep for webservers
    cat $domainName-comprehensive.gnmap | grep "open[^, ]*\(http\|sip\|ipp\|oem-agent\|soap\|snet-sensor-mgmt\|connect-proxy\|cpq-wbem\|event-port\|analogx\|proxy-plus\|saphostctrl\|saphostctrls\|spss\|sun-answerbook\|wsman\|wsmans\|wso2esb-console\|xmpp-bosh\)" | cut -d" " -f 2 | sort -u > ../$domainName-webservers.txt
fi 

echo -e "\e[102m[+] Screenshotting webservers with EyeWitness...\e[49m"

cd /opt/EyeWitness

# Run EyeWitness
python EyeWitness.py -f /opt/subdomagic/output/$domainName/$domainName-webservers.txt --web -d /opt/subdomagic/output/$domainName/$domainName-EyeWitness

cd /opt/subdomagic/output/$domainName
rm $domainName-amass.txt
rm $domainName-massdns.txt
rm $domainName-subfinder.txt

clear

cd /opt/subdomagic

cat logo.txt
echo -e "Checkout the \e[1m\"output\"\e[22m directory for: " 
echo -e ""
echo -e "[*] EyeWitness Report"
echo -e "[*] List of subdomains"
echo -e "[*] Nmap scans"
echo -e ""
echo -e  "\e[1mSubdomain enumeration complete!\e[22m"
