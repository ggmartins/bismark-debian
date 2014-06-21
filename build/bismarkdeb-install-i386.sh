#!/bin/bash

wget -c http://guilherme.noise.gatech.edu:8000/bismark-active_1.0-1_i386.deb
wget -c http://guilherme.noise.gatech.edu:8000/bismark-data-transmit_1.0-1_i386.deb
wget -c http://guilherme.noise.gatech.edu:8000/bismark-management-client_1.0-1_i386.deb
wget -c http://guilherme.noise.gatech.edu:8000/bismark-netcat-gnu_0.7.1-1_i386.deb
apt-get install netperf paris-traceroute d-itg curl libcurl3-gnutls
dpkg -i bismark-management-client_1.0-1_i386.deb
dpkg -i bismark-data-transmit_1.0-1_i386.deb
dpkg -i bismark-active_1.0-1_i386.deb
dpkg -i bismark-netcat-gnu_0.7.1-1_i386.deb
