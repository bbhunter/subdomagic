#!/bin/bash

# TODO - check for dependency installations
if [ ! d "output" ]; then
  exit "You have already installed subdomagic!"
fi 

echo -e "\e[102m[+] Installing dependencies....\e[49m"

mkdir output
_last=`pwd`

#install go
wget https://dl.google.com/go/go1.12.6.linux-amd64.tar.gz
tar -xf go1.12.6.linux-amd64.tar.gz

PATH="`pwd`/go/bin:${PATH}"
GOPATH="`pwd`/gopath"

echo -e "\e[102m[+] Installing amass...\e[49m"

#install amass
go get -u github.com/OWASP/Amass/...
cd $GOPATH/src/github.com/OWASP/Amass
go install ./...
cd _last

echo -e "\e[102m[+] Installing Subfinder...\e[49m"
#install subfinder
git clone https://github.com/subfinder/subfinder 
cd subfinder
go get github.com/subfinder/subfinder
sh build.sh
go build
cd _last

echo -e "\e[102m[+] Installing massdns...\e[49m"
#install massdns
git clone https://github.com/blechschmidt/massdns
cd massdns
make

cd lists
wget https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt
cd _last

echo -e "\e[102m[+] Installing Eyewitness...\e[49m"

#install EyeWitness
git clone https://github.com/FortyNorthSecurity/EyeWitness
cd EyeWitness
cd setup
./setup.sh
cd _last

#complete setup
echo -e "\e[1msubdomagic by gelosecurity.com\e[22m"
echo -e ""
echo -e "\e[92m[*] Installed snap"
echo -e "[*] Installed go"
echo -e "[*] Installed amass"
echo -e "[*] Installed subfinder"
echo -e "[*] Installed massdns"
echo -e "[*] Installed EyeWitness"
echo -e""
echo -e "\e[1mSetup complete!"

