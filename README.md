subdomagic
======
This linux script is intended to simplify the process of subdomain enumeration. Think of it as a "press this button and have it do all the things for subdomain web enumeration". In particular, it's looking to:

1. Enumerate and consolidate subdomains from multiple sources using multiple tools.
2. Conduct scans for web servers hosted on common ports. 
3. Take screenshots and output a report. 


### Setup
1. `git clone https://github.com/gelosecurity/subdomagic` into your `/opt` directory **(MUST BE IN OPT!)**
1. Navigate into the setup directory
2. Run the `setup.sh` script

### Usage

Due to long enumeration time, it is highly suggested to use this on a VPS or remote host, and use the `screen` command to keep the session running in the background. 

```bash
./subdomagic.sh
```
[1] `fast` is intended for host quick subdomain/host discovery and also includes a TCP and version scan of common ports for nmap's OS detection. Useful if you just want to see externally available webservers in a reasonable amount of time. 

[2] `comprehensive` is intended for extremely thorough subdomain enumeration and will scan the top 1000 TCP ports on each active host. Useful if you want a more comprehensive scan on what ports are available externally. This is intended as a "catch all method" as it uses Jason Haddix's [`all.txt`](https://gist.github.com/jhaddix/f64c97d0863a78454e44c2f7119c2a6a) for bruting subdomains.

### The Goodies

In the  directory `output`, you will have a directory based on the domain name `example.com`. 

In the directory `output/example.com`, the files included are
1. `domain-nmap-fast.gnmap` or/and `domain-nmap-comprehensive.gnmap` scan depending on whether or not you did a quick or verbose scan
2. `domain.eyewitness` folder and the `report.html` that is in it
3. `domain-subdomains.txt` for any subdomains you're interested in
4. `domain-webservers.txt` for the IPs of active webservers within the subdomain list


### Suggestions?
DM me on Twitter: https://twitter.com/gelosecurity

### Tools

* https://github.com/OWASP/Amass

* https://github.com/subfinder/subfinder

* https://github.com/blechschmidt/massdns

* https://github.com/FortyNorthSecurity/EyeWitness

* https://nmap.org/







