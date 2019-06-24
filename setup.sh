#!/bin/bash




echo "[+] Installing dependencies...."

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

echo "[+] Installing amass..."

#install amass
sudo snap install amass

echo "[+] Installing Subfinder..."
#install subfinder
cd /opt
git clone https://github.com/subfinder/subfinder
cd subfinder
go get github.com/subfinder/subfinder

echo "Installing massdns..."
#install massdns
cd /opt
git clone https://github.com/blechschmidt/massdns
cd massdns
make

echo "Installing Eyewitness..."

#install EyeWitness
cd /opt
git clone https://github.com/FortyNorthSecurity/EyeWitness
cd EyeWitness
cd setup
./setup.sh

echo "Setup complete!"


