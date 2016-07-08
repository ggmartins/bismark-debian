#!/bin/bash

apt-get update

#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-active_1.0-1_armhf.deb
#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-data-transmit_1.0-1_armhf.deb
#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-management-client_1.0-1_armhf.deb
#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-netcat-gnu_0.7.1-1_armhf.deb
#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-dropbear_2011.54-1_armhf.deb
#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-shaperprobe_2009.10_armhf.deb
#wget -c http://downloads.projectbismark.net/debian/armhf/bismark-netperf_2.4.4-1_armhf.deb
apt-get -yqf install time
apt-get -yqf install fping
apt-get -yqf install dnsutils
apt-get -yqf install busybox
#apt-get -yqf install netperf
apt-get -yqf install paris-traceroute
apt-get -yqf install d-itg
apt-get -yqf install curl
apt-get -yqf install libcurl3-gnutls
dpkg -i bismark-netcat-gnu_0.7.1-1_armhf.deb
dpkg -i bismark-dropbear_2011.54-1_armhf.deb
dpkg -i bismark-management-client_1.0-1_armhf.deb
dpkg -i bismark-data-transmit_1.0-1_armhf.deb
dpkg -i bismark-active_1.0-1_armhf.deb
dpkg -i bismark-netperf_2.4.4-1_armhf.deb
dpkg -i bismark-shaperprobe_2009.10_armhf.deb

