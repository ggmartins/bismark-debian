#!/bin/bash

apt-get update

#wget -c http://guilherme.noise.gatech.edu:8000/bismark-active_1.0-1_armhf.deb
#wget -c http://guilherme.noise.gatech.edu:8000/bismark-data-transmit_1.0-1_armhf.deb
#wget -c http://guilherme.noise.gatech.edu:8000/bismark-management-client_1.0-1_armhf.deb
#wget -c http://guilherme.noise.gatech.edu:8000/bismark-netcat-gnu_0.7.1-1_armhf.deb
#wget -c http://guilherme.noise.gatech.edu:8000/bismark-dropbear_2011.54-1_armhf.deb
#wget -c http://guilherme.noise.gatech.edu:8000/bismark-shaperprobe_2009.10_armhf.deb
#wget -c http://guilherme.noise.gatech.edu:8000/bismark-netperf_2.4.4-1_armhf.deb
apt-get -y install netperf paris-traceroute d-itg curl libcurl3-gnutls fping dnsutils time
dpkg -i bismark-netcat-gnu_0.7.1-1_armhf.deb
dpkg -i bismark-dropbear_2011.54-1_armhf.deb
dpkg -i bismark-management-client_1.0-1_armhf.deb
dpkg -i bismark-data-transmit_1.0-1_armhf.deb
dpkg -i bismark-active_1.0-1_armhf.deb
dpkg -i bismark-netperf_2.4.4-1_armhf.deb
dpkg -i bismark-shaperprobe_2009.10_armhf.deb

