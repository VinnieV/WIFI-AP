#! /bin/bash
# Written by Vinnie Vanhoecke
# Script to start an AP
# Make sure you edited all the configuration files and have hostapd and dnsmasq installed
# "sudo ./startAP.sh all"  --> Will capture all traffic

# Variables
# Access point interface
apInterface="wlan1"
outInterface="wlan0"
all=false
ssid=🐼🐼🐼🐼🐼🐼🐼

# Arguments: -i -o -a 
# Parsing arguments
while getopts i:o:as:h option
do
case "${option}"
in
h) 
	echo "##############################################################"
	echo "sudo ./startAP.sh -i wlan0 -o eth0 -s ssid -a"
	echo "-i : Interface to create the AP on"
	echo "-o : Outbound traffic interface for connectivity"
	echo "-a : Forward HTTP(S) traffic to localhost:8080"
	echo "-s : SSID name"
	echo "-h : This helpmenu"
	echo "Default values for the options can be defined in the script."
	echo "##############################################################"
	exit;;
i) apInterface=${OPTARG};;
o) outInterface=${OPTARG};;
s) ssid=${OPTARG};;
a) all=false;;
esac
done

# Creating config files if neccesary
if [ ! -f /etc/dnsmasq.conf ]; then
	echo "Copying dnsmasq config file"
    cp dnsmasq.conf /etc/dnsmasq.conf
fi
if [ ! -f /etc/hostapd.conf ]; then
	echo "Copying hostapd config file"
    cp hostapd.conf /etc/hostapd.conf
fi
# Changing configuration files
echo "Changing dnsmasq config"
sed -i -e "s/interface=.*/interface=$apInterface/g" /etc/dnsmasq.conf
echo "Changing hostapd config"
sed -i -e "s/interface=.*/interface=$apInterface/g" /etc/hostapd.conf
sed -i -e "s/ssid=.*/ssid=$ssid/g" /etc/hostapd.conf
echo "############################################"
echo "###########Starting Access Point############"
echo "############################################"
echo "1) We have to kill wpa_supplicant first"
killall wpa_supplicant
sleep 2
echo "2) Restarting dnsmasq"
service dnsmasq stop
service dnsmasq start

echo "3) Configure wlan0 interface (ip 10.0.0.1)"
ifconfig $apInterface up
ifconfig $apInterface 10.0.0.1/24

echo "4) Configuring iptables to forward traffic"
iptables -t nat -F
iptables -F
iptables -t nat -A POSTROUTING -o $outInterface -j MASQUERADE
iptables -A FORWARD -i $apInterface -o $outInterface -j ACCEPT
echo '1' > /proc/sys/net/ipv4/ip_forward

# Check for all parameter
if [ all = true ]; then
    echo "Forwarding all HTTP and HTTPS traffic(80&443) to localhost:8080"
    iptables -t nat -A PREROUTING -p tcp --dport 443 -j REDIRECT --to-port 8080
    iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 8080
fi

echo "5) Starting hostapd"
service hostapd stop
service hostapd start