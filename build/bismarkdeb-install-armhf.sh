#!/bin/bash

apt-get update

#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-active_1.0-1_armhf.deb
#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-data-transmit_1.0-1_armhf.deb
#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-management-client_1.0-1_armhf.deb
#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-netcat-gnu_0.7.1-1_armhf.deb
#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-dropbear_2011.54-1_armhf.deb
#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-shaperprobe_2009.10_armhf.deb
#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-netperf_2.4.4-1_armhf.deb
apt-get -yqf install vim
apt-get -yqf install time
apt-get -yqf install fping
apt-get -yqf install dnsutils
apt-get -yqf install busybox
apt-get -yqf install paris-traceroute
apt-get -yqf install d-itg
apt-get -yqf install curl
apt-get -yqf install libcurl3-gnutls
apt-get -yqf install isc-dhcp-server 
apt-get -yqf install iftop
apt-get -yqf install tcpdump
apt-get -yqf install tshark 
#apt-get -yqf install dropbear

apt-get remove --purge -y network-manager

#while true; do
#    read -p "Do you wish to apply the BISmark package configuration for isc-dhcp-server and dhcpcd ? [y/n] " yn
#    case $yn in
#        [Yy]* )
#                echo "Proceeding with installation..."
#             break;;
#        [Nn]* ) echo "OK"
#             exit 1;;
#        * ) echo "Please answer yes or no.";;
#    esac
#done

dpkg -i bismark-netcat-gnu_0.7.1-1_armhf.deb
dpkg -i bismark-dropbear_2011.54-1_armhf.deb
dpkg -i bismark-management-client_1.0-1_armhf.deb
dpkg -i bismark-data-transmit_1.0-1_armhf.deb
dpkg -i bismark-active_1.0-1_armhf.deb
dpkg -i bismark-netperf_2.4.4-1_armhf.deb
dpkg -i bismark-shaperprobe_2009.10_armhf.deb

cat << "EOF" | tee /etc/init.d/bismark-firstboot > /dev/null
#!/bin/sh
### BEGIN INIT INFO
# Provides:          bismark-firstboot
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: bismark-nat
# Description:       initial bismark commands
### END INIT INFO
/usr/bin/bismark-bootstrap
sed -i "s/raspberrypi/$(cat \/etc\/bismark\/ID)/g" /etc/hosts
sed -i "s/raspberrypi/$(cat \/etc\/bismark\/ID)/g" /etc/hostname
rm $0
/sbin/reboot
EOF

chmod +x /etc/init.d/bismark-firstboot
update-rc.d bismark-firstboot defaults

cat << "EOF" | tee /etc/init.d/bismark-nat > /dev/null
#!/bin/sh
### BEGIN INIT INFO
# Provides:          bismark-nat
# Required-Start:    $local_fs $network
# Required-Stop:     $local_fs
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: bismark-nat
# Description:       enable NAT for any traffic comming from eth0
### END INIT INFO
IFOUT="eth0"
touch /var/lock/bismark-nat
case "$1" in
  start)
    echo "Starting bismark-nat..."
    modprobe iptable_nat
    iptables -t nat -A POSTROUTING -o $IFOUT -j MASQUERADE
    echo 1 > /proc/sys/net/ipv4/ip_forward
    /usr/bin/bismark-setdns
    echo "Done."
    ;;
  stop)
    echo "Stopping bismark-nat..."
    echo 0 > /proc/sys/net/ipv4/ip_forward
    echo "Done."
    ;;
  *)
    echo "Usage: /etc/init.d/bismark-nat {start|stop}"
    exit 1
    ;;
esac
exit 0
EOF

chmod +x /etc/init.d/bismark-nat
update-rc.d bismark-nat defaults

cat << "EOF" | tee /etc/network/interfaces.d/eth > /dev/null
allow-hotplug eth1
auto eth1
    iface eth1 inet static
    address 192.168.143.1
    netmask 255.255.255.0
    network 192.168.143.0
EOF

echo "INTERFACES=\"eth1\"" > /etc/default/isc-dhcp-server

cat << "EOF" | tee /etc/dhcp/dhcpd.conf > /dev/null
ddns-update-style none;
default-lease-time 600;
max-lease-time 7200;
log-facility local7;
subnet 192.168.143.0 netmask 255.255.255.0 {range 192.168.143.10 192.168.143.200; option routers 192.168.143.1;}
include "/etc/dhcpd.name-servers.tmp";
EOF

cat << "EOF" | tee /usr/bin/bismark-setdns > /dev/null
#!/usr/bin/env bash

if [ -f /etc/resolv.conf ];then
  ns=$(cat /etc/resolv.conf  | grep -v "^#" | grep nameserver | awk '{print $2}')
fi
ns2=""
for i in $ns; 
do 
  if [[ $i =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
    ns2=$ns2$i", "
  fi
done
if [ -z "$ns" ];then
  my_domain_name_servers="8.8.8.8, 4.2.2.2"
else
 my_domain_name_servers=$(echo $ns2 | sed "s/,$//") 
fi
echo "option domain-name-servers $my_domain_name_servers ;">/tmp/dhcpd.name-servers.new

diff /etc/dhcpd.name-servers.tmp /tmp/dhcpd.name-servers.new > /dev/null 2>&1
if [[ $? -gt 0 ]]; then
      cp /tmp/dhcpd.name-servers.new /etc/dhcpd.name-servers.tmp
      /etc/init.d/isc-dhcp-server restart
      echo "dhcp restart dns" > /tmp/dhcpd.state.bad
fi

dhcpd_stat=`/etc/init.d/isc-dhcp-server status`
dhcpd_stat_code=$?
dhcp_stat_iface=`echo $dhcpd_stat | grep -c "receive_packet failed"`
if [[ $dhcpd_stat_code -gt 0 || $dhcp_stat_iface -gt 0 ]]; then
        /etc/init.d/isc-dhcp-server restart
        echo "dhcp restart" > /tmp/dhcpd.state.bad
        [ -f /ta/wrapper.sh ] && /ta/wrapper.sh -k
else
        echo "dhcp good" > /tmp/dhcpd.state.good
fi
EOF
chmod +x /usr/bin/bismark-setdns
echo "* * * * * root /usr/bin/bismark-setdns" > /etc/cron.d/cron-bismark-setdns
chmod +x /etc/cron.d/cron-bismark-setdns
/etc/init.d/cron reload

systemctl disable avahi-daemon

sed -i "s/#ListenAddress 0.0.0.0/ListenAddress 192.168.143.1/" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin without-password/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
/etc/init.d/ssh restart

rm -f /etc/udev/rules.d/70-persistent-net.rules

echo "Please reboot device."
