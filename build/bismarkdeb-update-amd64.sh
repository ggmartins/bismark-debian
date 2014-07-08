#!/bin/sh

for i in $(dpkg -l | grep bismark | grep -v drop | awk '{ print $2 }'); do
echo processing [$i]...
/etc/init.d/bismark-active stop
/etc/init.d/bismark-data-transmit stop
apt-get -y --purge remove $i
rm -rf /tmp/bismark*
rm -rf /etc/cron.d/cron-bismark*
done

cd /tmp/
wget -c http://downloads.projectbismark.net/debian/bismark-active_1.0-1_amd64.deb
wget -c http://downloads.projectbismark.net/debian/bismark-data-transmit_1.0-1_amd64.deb
wget -c http://downloads.projectbismark.net/debian/bismark-management-client_1.0-1_amd64.deb
wget -c http://downloads.projectbismark.net/debian/bismark-netcat-gnu_0.7.1-1_amd64.deb
apt-get -y install netperf paris-traceroute d-itg curl libcurl3-gnutls fping
dpkg -i bismark-netcat-gnu_0.7.1-1_amd64.deb
dpkg -i bismark-management-client_1.0-1_amd64.deb
dpkg -i bismark-data-transmit_1.0-1_amd64.deb
dpkg -i bismark-active_1.0-1_amd64.deb
cd -

