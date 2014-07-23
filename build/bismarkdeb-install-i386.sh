#!/bin/bash

wget -c http://downloads.projectbismark.net/bismark-active_1.0-1_i386.deb
wget -c http://downloads.projectbismark.net/bismark-data-transmit_1.0-1_i386.deb
wget -c http://downloads.projectbismark.net/bismark-management-client_1.0-1_i386.deb
wget -c http://downloads.projectbismark.net/bismark-netcat-gnu_0.7.1-1_i386.deb
apt-get install netperf paris-traceroute d-itg curl libcurl3-gnutls fping dnsutils time
dpkg -i bismark-management-client_1.0-1_i386.deb
dpkg -i bismark-data-transmit_1.0-1_i386.deb
dpkg -i bismark-active_1.0-1_i386.deb
dpkg -i bismark-netcat-gnu_0.7.1-1_i386.deb
bismark-dropbear_2011.54-1_amd64.deb
