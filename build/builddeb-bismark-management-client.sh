#!/bin/bash

export DEB_BUILD_OPTIONS=nostrip
TARGETDIR=bismark-management-client-1.0

if [ "$1" = "nodownload" ];
 then
    echo "Not checking out/downloading latest code, using existing dir $TARGETDIR..."
 else
    rm -rf bismark-management-client
    rm -rf $TARGETDIR
    git clone https://github.com/projectbismark/bismark-management-client.git

    mv bismark-management-client $TARGETDIR
    cd $TARGETDIR
    git checkout debian
    cd -
fi

tar cvzf bismark-management-client_1.0.orig.tar.gz $TARGETDIR
mkdir -p $TARGETDIR/debian

cat << "EOF" | tee $TARGETDIR/debian/changelog > /dev/null
bismark-management-client (1.0-1) UNRELEASED; urgency=low

  * Initial release. (Closes: #XXXXXX)

 -- Guilherme Grillo Martins <gmartins@gatech.edu>  Wed, 11 Jun 2014 18:01:56 +0000
EOF

echo "9" > $TARGETDIR/debian/compat

cat << "EOF" | tee $TARGETDIR/debian/control > /dev/null
Source: bismark-management-client
Maintainer: Guilherme G. Martins <gmartins@gatech.edu>
Section: misc
Priority: optional
Standards-Version: 3.9.4
Build-Depends: debhelper (>= 9)

Package: bismark-management-client
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}, curl
Description: BISMark Management Client scripts
 BISMArk Broadband Internet Services beanchMARK

EOF

cat << "EOF" | tee $TARGETDIR/debian/postinst > /dev/null
#!/bin/bash
set -e
if [ -x /usr/bin/bismark-bootstrap ]; then
  bismark-bootstrap
  echo "@reboot root /usr/bin/bismark-bootstrap >> /tmp/bismark-scripts-mgmt.log 2>&1" >/etc/cron.d/cron-bismark-bootstrap
  chmod +x /etc/cron.d/cron-bismark-bootstrap
  echo "*/1  * * * * root /usr/bin/bismark-probe >> /tmp/bismark-scripts-mgmt.log 2>&1" >/etc/cron.d/cron-bismark-mgmt
  echo "0 */12 * * * root /usr/bin/bismark-action scriptupdate >> /tmp/bismark-scripts-mgmt.log 2>&1" >>/etc/cron.d/cron-bismark-mgmt
  echo "5 */12 * * * root /usr/bin/bismark-action mgmtconfupdate >> /tmp/bismark-scripts-mgmt.log 2>&1" >>/etc/cron.d/cron-bismark-mgmt
  chmod +x /etc/cron.d/cron-bismark-mgmt
fi
#DEBHELPER#
EOF


touch $TARGETDIR/debian/copyright
#echo "1.0 lancre" > $TARGETDIR/debian/source/format

cat << "EOF" | tee $TARGETDIR/debian/rules > /dev/null
#!/usr/bin/make -f
export DH_VERBOSE=1
%:
	dh $@

override_dh_auto_install:
	mkdir -p $$(pwd)/debian/bismark-management-client/etc/bismark/
	mkdir -p $$(pwd)/debian/bismark-management-client/usr/bin/
	mkdir -p $$(pwd)/debian/bismark-management-client/usr/lib/bismark
	mkdir -p $$(pwd)/debian/bismark-management-client/etc/ssl/certs/
	cp $$(pwd)/usr/bin/* $$(pwd)/debian/bismark-management-client/usr/bin/
	cp $$(pwd)/usr/lib/bismark/functions.inc.sh $$(pwd)/debian/bismark-management-client/usr/lib/bismark/
	cp $$(pwd)/etc/bismark/* $$(pwd)/debian/bismark-management-client/etc/bismark
	cp $$(pwd)/etc/ssl/certs/* $$(pwd)/debian/bismark-management-client/etc/ssl/certs/
EOF

chmod +x $TARGETDIR/debian/rules

#$(MAKE) DESTDIR=$$(pwd)/debian/bismark-data-transmit prefix=/usr/bin install

cd $TARGETDIR
debuild -us -uc
#debuild -ai386 -us -uc
cd -

echo END
