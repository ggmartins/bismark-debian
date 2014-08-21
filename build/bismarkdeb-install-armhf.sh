#!/bin/bash

apt-get update

wget -c http://downloads.projectbismark.net/armhf/bismark-active_1.0-1_armhf.deb
wget -c http://downloads.projectbismark.net/armhf/bismark-data-transmit_1.0-1_armhf.deb
wget -c http://downloads.projectbismark.net/armhf/bismark-management-client_1.0-1_armhf.deb
wget -c http://downloads.projectbismark.net/armhf/bismark-netcat-gnu_0.7.1-1_armhf.deb
wget -c http://downloads.projectbismark.net/armhf/bismark-dropbear_2011.54-1_armhf.deb
wget -c http://downloads.projectbismark.net/armhf/bismark-shaperprobe_2009.10_armhf.deb
wget -c http://downloads.projectbismark.net/armhf/bismark-netperf_2.4.4-1_armhf.deb
apt-get -y install netperf paris-traceroute d-itg curl libcurl3-gnutls fping dnsutils time
dpkg -i bismark-netcat-gnu_0.7.1-1_armhf.deb
dpkg -i bismark-dropbear_2011.54-1_armhf.deb
dpkg -i bismark-management-client_1.0-1_armhf.deb
dpkg -i bismark-data-transmit_1.0-1_armhf.deb
dpkg -i bismark-active_1.0-1_armhf.deb
dpkg -i bismark-netperf_2.4.4-1_armhf.deb
dpkg -i bismark-shaperprobe_2009.10_armhf.deb

