#!/bin/bash

echo "\e[102m[+] Installing dependencies....\e[49m"

mkdir output

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

echo "\e[102m[+] Installing amass...\e[49m"

#install amass
sudo snap install amass

echo "\e[102m[+] Installing Subfinder...\e[49m"
#install subfinder
cd /opt
git clone https://github.com/subfinder/subfinder
cd subfinder
go get github.com/subfinder/subfinder
sh build.sh
go build

echo "\e[102m[+] Installing massdns...\e[49m"
#install massdns
cd /opt
git clone https://github.com/blechschmidt/massdns
cd massdns
make

cd /opt/massdns/lists
wget https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt

echo "\e[102m[+] Installing Eyewitness...\e[49m"

#install EyeWitness
cd /opt
git clone https://github.com/FortyNorthSecurity/EyeWitness
cd EyeWitness
cd setup
./setup.sh

clear

#complete setup
echo "\e[1msubdomagic by gelosecurity.com\e[21m"
echo "\e[92m[*] Installed snap"
echo "[*] Installed go"
echo "[*] Installed amass"
echo "[*] Installed subfinder"
echo "[*] Installed massdns"
echo "[*] Installed EyeWitness"
echo""
echo "\e[1mSetup complete!"


