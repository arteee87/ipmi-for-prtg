# ipmi-for-prtg
Get your old and unsupported IPMI sensors data to PRTG using ipmitool on the host system and SSH advanced script sensor in PRTG

1) download the "ipmi.sh" to your host system to /var/prtg/scriptsxml/
2) chmod +x /var/prtg/scriptsxml/ipmi.sh
3) add "SSH Script Advanced Sensor" in your PRTG, select "ipmi.sh" in the list

Tested on Supermicro X9DRi-LN4F+ board ver. 1.10, bios ver. 03.48
