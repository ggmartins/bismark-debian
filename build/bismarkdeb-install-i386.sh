#!/bin/bash

apt-get update

wget -c http://downloads.projectbismark.net/i386/bismark-active_1.0-1_i386.deb
wget -c http://downloads.projectbismark.net/i386/bismark-data-transmit_1.0-1_i386.deb
wget -c http://downloads.projectbismark.net/i386/bismark-management-client_1.0-1_i386.deb
wget -c http://downloads.projectbismark.net/i386/bismark-netcat-gnu_0.7.1-1_i386.deb
wget -c http://downloads.projectbismark.net/i386/bismark-dropbear_2011.54-1_i386.deb
wget -c http://downloads.projectbismark.net/i386/bismark-shaperprobe_2009.10_i386.deb
wget -c http://downloads.projectbismark.net/i386/bismark-netperf_2.4.4-1_i386.deb
apt-get -y install netperf paris-traceroute d-itg curl libcurl3-gnutls fping dnsutils time
dpkg -i bismark-netcat-gnu_0.7.1-1_i386.deb
dpkg -i bismark-dropbear_2011.54-1_i386.deb
dpkg -i bismark-management-client_1.0-1_i386.deb
dpkg -i bismark-data-transmit_1.0-1_i386.deb
dpkg -i bismark-active_1.0-1_i386.deb
dpkg -i bismark-netperf_2.4.4-1_i386.deb
dpkg -i bismark-shaperprobe_2009.10_i386.deb

