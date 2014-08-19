#!/bin/sh

/etc/init.d/bismark-active stop
/etc/init.d/bismark-data-transmit stop

BISMARK_DEB_LIST=`dpkg -l | grep bismark | awk '{ print$2 }'`

for pkg in $BISMARK_DEB_LIST; do
echo removing $pkg 
apt-get -y --purge remove $pkg

done

rm -fR /etc/bismark
