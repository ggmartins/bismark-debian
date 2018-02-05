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
#apt-get -yqf install isc-dhcp-server 
apt-get -yqf install dnsmasq
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
#!/bin/bash
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

if [ -f /etc/salt/minion_id ];then
  let "D=$RANDOM % 9999"
  if (($D < 1000)); then
    let "D = (D+1000)"
  fi
  echo "test_${D}" > /etc/salt/minion_id
  rm $0
  /sbin/reboot
else
  echo "WARNING: MINION ID (/etc/salt/minion_id) NOT FOUND"
fi
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

cat << "EOF" | tee /etc/dnsmasq.d/dnsmasq-bismark.conf > /dev/null
bogus-priv
interface=eth1
except-interface=eth0
listen-address=192.168.143.1
dhcp-range=192.168.143.10,192.168.143.250,255.255.255.0,24h
dhcp-option=option:router,192.168.143.1
log-facility=/var/log/dnsmasq.log
dhcp-leasefile=/tmp/dhcp.leases
stop-dns-rebind
domain-needed
bind-interfaces
dhcp-authoritative
cache-size=0
log-dhcp
EOF

echo "conf-dir=/etc/dnsmasq.d/" > /etc/dnsmasq.conf

/etc/init.d/cron reload

systemctl disable avahi-daemon

sed -i "s/#ListenAddress 0.0.0.0/ListenAddress 192.168.143.1/" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin without-password/PermitRootLogin no/" /etc/ssh/sshd_config
sed -i "s/PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config
/etc/init.d/ssh restart

rm -f /etc/udev/rules.d/70-persistent-net.rules

#curl -o bootstrap-salt.sh -L https://bootstrap.saltstack.com
#curl -o bootstrap-salt.sh -L http://downloads.projectbismark.net/rpi/bootstrap-salt.sh
#sh bootstrap-salt.sh -r -P git v2016.11.1
curl -o bootstrap-salt.sh https://raw.githubusercontent.com/saltstack/salt-bootstrap/develop/bootstrap-salt.sh
sh bootstrap-salt.sh -r -P git 2017.7

if [ ! -d /etc/salt/minion.d/ ]; then
  echo "WARNING: Error installing salt stack"
  exit
else
  sed -i "s/#default_include: minion.d\/\*\.conf/default_include: minion.d\/\*\.conf/" /etc/salt/minion
fi

cat << "EOF" | tee /etc/salt/minion.d/test1.conf > /dev/null
master:
  - trafficanalysis.princeton.edu
master_port: 44506
EOF

echo "Please reboot device."
