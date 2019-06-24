subdomagic
======
Hello! This script is intended to speed up and simplify the process of subdomain enumeration. In particular, it's looking to:

1. Enumerate subdomains using efficient open source tools (Amass, Subfinder, MassDNS)
2. Conduct scans for web servers hosted on common ports. 
3. Take screenshots and output a report. (EyeWitness)


### Setup
1. Navigate into the setup directory
2. Run the `setup.sh` script

### Usage
```bash
./subdomagic.sh
```
[1] `fast` is intended for host quick host discovery and also includes a TCP and version scan of common ports for nmap's OS detection. Useful if you just want to see externally available webservers.

[2] `comprehensive` is intended for more thorough enumeration and will scan the top 1000 TCFP ports. Useful if you want a more comprehensive scan on what ports are available externally.

### The Goodies

In the directory `output`, you will have a directory based on the domain name `example.com`. 

[Image here]

In the directory, the most important files would probably be:
1. `domain-fast.gnmap` scan depending on whether or not you did a quick or verbose scan
2. `domain.eyewitness` folder and the `report.html` that is in it
3. `domain.subdomains.txt` for any subdomains you're interested in







