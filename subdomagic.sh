#!/bin/bash

if [ ! -d "output" ]; then
  exit "Please run setup.sh"
fi 

# clear terminal (aesthetic!)
clear

# banner (aesthetic!)
cat logo.txt

# prompt user for doamin
echo ""
echo "Enter your target domain (such as \"example.com\"): "

read domainName

# prompt user for nmap settings
echo ""
echo "Would you like fast or comprehensive output from the port scan?"
echo ""
echo "[1] Fast - 8 Common Ports"
echo "[2] Comprehensive - TCP Top 1000"
echo ""

read nmapChoice

echo ""
echo -e "[+] Making directory structure..."

# make directory structure
cd output

if [ ! -d "$domainName" ]; then
  mkdir $domainName
fi

cd $domainName

echo -e "[+] Running subodmain enumeration...this may take a while..."

# run amass
amass enum -o $domainName-amass.txt -d $domainName
mv $domainName-amass.txt /opt/subdomagic/output/$domainName

# run subfinder
cd /opt/subfinder
./subfinder -d $domainName -o /opt/subdomagic/output/$domainName/$domainName-subfinder.txt

# run massdns
cd /opt/massdns/scripts
python subbrute.py all.txt $domainName | ./bin/massdns -r lists/resolvers.txt -t A -o S -w /opt/subdomagic/output/$domainName/$domainName-massdns.txt

echo -e "[+] Consolidating subdomain findings..."

cd /opt/subdomagic/output/$domainName

# dedup all subdomain findings 
cat $domainName-amass.txt $domainName-subfinder.txt $domainName-massdns.txt > $domainName-subdomains.txt

sort $domainName-subdomains.txt | uniq -u > $domainName-subdomains.txt

rm $domainName-amass.txt
rm $domainName-subfinder.txt
rm $domainName-massdns.txt

echo -e "[+] Conducting initial scan..."

cd /opt/subdomagic/output/$domainName
mkdir nmap_scans
cd nmap_scans

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
    echo -e "[+] Conducting comprehensive scan..."
    #grep for online hosts
    grep -i "status: up" $domainName-nmap-fast.gnmap | awk -F" " '{print $2}' > $domainName-online.txt

    #nmap for tcp 1000
    nmap -oA $domainName-comprehensive --stats-every 60s --log-errors --reason --randomize-hosts -v -R -Pn -A -sSVC --top-ports 1000 -iL $domainName-nmap-fast.gnmap

    # grep for webservers
    cat $domainName-comprehensive.gnmap | grep "open[^, ]*\(http\|sip\|ipp\|oem-agent\|soap\|snet-sensor-mgmt\|connect-proxy\|cpq-wbem\|event-port\|analogx\|proxy-plus\|saphostctrl\|saphostctrls\|spss\|sun-answerbook\|wsman\|wsmans\|wso2esb-console\|xmpp-bosh\)" | cut -d" " -f 2 | sort -u > $domainName-webservers.txt
fi 

echo -e "[+] Screenshotting webservers with EyeWitness..."

cd /opt/EyeWitness

# Run EyeWitness
python EyeWitness.py -f /opt/subdomagic/$domainName/$domainName-webservers.txt --web -d /opt/subdomagic/$domainName/$domainName-EyeWitness





