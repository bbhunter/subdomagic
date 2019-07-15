#!/bin/bash

if [[ -d "output" ]]; then
  exit "You have already installed subdomagic!"
fi 

if [ "${UID}" != '0' ]; then
  echo '[Error]: You must run this setup script with root privileges.'
  echo
  exit 1
fi

#current directory
cur_dir=`pwd`

echo -e "\e[102m[+] Installing dependencies...\e[49m"

mkdir tools
mkdir output
echo -e "\e[102m[+] Installing nmap...\e[49m"
sudo apt-get -y install nmap

# install make for massdns
sudo apt install make

# install gcc for massdns
sudo apt install gcc

# install snap 
sudo apt install snapd
sudo systemctl start snapd
sudo systemctl enable snapd
sudo systemctl start apparmor
sudo systemctl enable apparmor
echo "PATH=$PATH:/snap/bin" >> ~/.bashrc
source ~/.bashrc
sudo snap refresh

#install go
sudo snap install --classic go

echo -e "\e[102m[+] Installing amass...\e[49m"

#install amass
sudo snap install amass

echo -e "\e[102m[+] Installing Subfinder...\e[49m"
#install subfinder
cd $cur_dir/tools
git clone https://github.com/subfinder/subfinder
cd subfinder
go get github.com/subfinder/subfinder
sh build.sh
go build

echo -e "\e[102m[+] Installing massdns...\e[49m"
#install massdns
cd $cur_dir/tools
git clone https://github.com/blechschmidt/massdns
cd massdns
make

cd $cur_dir/tools/massdns/lists
wget https://gist.githubusercontent.com/jhaddix/86a06c5dc309d08580a018c66354a056/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt

echo -e "\e[102m[+] Installing Eyewitness...\e[49m"

#install EyeWitness
cd $cur_dir/tools
git clone https://github.com/FortyNorthSecurity/EyeWitness
cd EyeWitness
cd setup
./setup.sh

clear

#complete setup
echo -e "\e[1msubdomagic by gelosecurity.com\e[22m"
echo -e ""
echo -e "\e[92m[[*] Installed nmap"
echo -e "[*] Installed make"
echo -e "[*] Installed gcc"
echo -e "[*] Installed snap"
echo -e "[*] Installed go"
echo -e "[*] Installed amass"
echo -e "[*] Installed subfinder"
echo -e "[*] Installed massdns"
echo -e "[*] Installed EyeWitness"
echo -e ""
echo -e "\e[1mSetup complete!"

