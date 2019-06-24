#!/bin/bash

GREEN = '\033[1;32'
YELLOW = '\033[1;33'


echo -e "${YELLOW}[+] Installing dependencies...."

#update
sudo apt-get update

# install snap 
sudo apt install snapd
sudo systemctl start snapd
sudo systemctl enable snapd
sudo systemctl start apparmor
sudo systemctl enable apparmor
export PATH=$PATH:/snap/bin
sudo snap refresh

#install go
sudo snap install --classic go

echo -e "${YELLOW}[+] Installing amass..."

#install amass
sudo snap install amass

echo -e "${YELLOW}[+] Installing Subfinder..."
#install subfinder
cd /opt
git clone https://github.com/subfinder/subfinder
go get github.com/subfinder/subfinder

echo -e "${YELLOW}Installing massdns..."
#install massdns
git clone https://github.com/blechschmidt/massdns
cd massdns
make
cd ..

echo -e "${YELLOW}Installing Eyewitness..."

#install EyeWitness
git clone https://github.com/FortyNorthSecurity/EyeWitness
cd setup
./setup.sh

echo -e "${GREEN}Setup compelte!"


