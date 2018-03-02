# Introduction
When performing mobile penetration test I usually set up a WIFI access point with my WIFI dongle to connect my mobile devices. It gives me the advantage to forward all traffic on network level to my local proxy server. Useful when you want to analyse the HTTP(S) requests from the mobile device.

# Requirements 
The packages dnsmasq and hostapd are required to set it up.
`sudo apt-get update && sudo apt-get install dnsmasq hostapd`

## Configure hostapd
Hostapd is the tool that will create an AP via the WIFI dongle.
1. Copy hostapd.conf file to /etc/hostapd.conf

```sudo cp hostapd.conf /etc/hostapd.conf```
2. Open up /etc/init.d/hostapd in a text-editor

```sudo vim /etc/init.d/hostapd```
3. Search for the line:

```DEAMON_CONF=```    
Change it to:

```DEAMON_CONF=/etc/hostapd.conf```


# Usage
```
sudo ./startAP.sh -i wlan0 -o eth0 -a
-i : Interface to create the AP on
-o : Outbound traffic interface for connectivity
-a : Forward HTTP(S) traffic to localhost:8080
-s : SSID name
-h : This helpmenu
Default values for the options can be defined in the script.
```

# Example
Start AP and forward all HTTP&HTTPS traffic to localhost:8080
(Useful for when you want to intercept the HTTP traffic in a proxy)

```sudo ./startAP.sh -i wlan0 -o eth0 -a -s mobile-ap```

