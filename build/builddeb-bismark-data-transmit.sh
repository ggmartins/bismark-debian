#!/bin/bash

apt-get install git
apt-get install devscripts
apt-get install libcurl4-gnutls-dev
apt-get install libssl-dev

#export DEB_BUILD_OPTIONS=nostrip
TARGETDIR=bismark-data-transmit-1.0

rm -rf bismark-data-transmit
rm -rf $TARGETDIR
rm -rf bismark-packages
git clone https://github.com/projectbismark/bismark-packages.git
git clone https://github.com/projectbismark/bismark-data-transmit.git


cd bismark-packages
git checkout debian
cd -

cd bismark-data-transmit
git checkout debian
cd -

mv bismark-data-transmit $TARGETDIR

tar cvzf bismark-data-transmit_1.0.orig.tar.gz $TARGETDIR
mkdir -p $TARGETDIR/debian

#cd $TARGETDIR
#dch --create -v 1.0-1 --package bismark-data-transmit
#cd -

cat << "EOF" | tee $TARGETDIR/debian/changelog > /dev/null
bismark-data-transmit (1.0-1) UNRELEASED; urgency=low

  * Initial release. (Closes: #XXXXXX)

 -- Guilherme Grillo Martins <gmartins@cc.gatech.edu>  Wed, 11 Jun 2014 18:01:56 +0000
EOF

echo "9" > $TARGETDIR/debian/compat

cat << "EOF" | tee $TARGETDIR/debian/control > /dev/null
Source: bismark-data-transmit
Maintainer: Guilherme G. Martins <gmartins@cc.gatech.edu>
Section: misc
Priority: optional
Standards-Version: 3.9.4
Build-Depends: debhelper (>= 9)

Package: bismark-data-transmit
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: BISmark Experiments Data Transmit
 BISMArk Broadband Internet Services beanchMARK

EOF

cat << "EOF" | tee $TARGETDIR/debian/postinst > /dev/null
#!/bin/bash

if [ -x /etc/init.d/bismark-data-transmit ]; then
  update-rc.d -f bismark-data-transmit defaults
fi
#  /etc/init.d/bismark-data-transmit start
#  ln -s /etc/init.d/bismark-data-transmit /etc/rc6.d/K01bismark-data-transmit
#  echo "@reboot root /etc/init.d/bismark-data-transmit start >> /tmp/bismark-scripts.log 2>&1" >/etc/cron.d/cron-bismark-data-transmit

EOF
chmod +x $TARGETDIR/debian/postinst


cat << "EOF" | tee $TARGETDIR/debian/postrm > /dev/null
#!/bin/bash

if [ -x /etc/init.d/bismark-data-transmit ]; then
  update-rc.d -f bismark-data-transmit remove
fi

EOF
chmod +x $TARGETDIR/debian/postrm


touch $TARGETDIR/debian/copyright
echo "1.0 lancre" > $TARGETDIR/debian/source/format

cat << "EOF" | tee $TARGETDIR/debian/rules > /dev/null
#!/usr/bin/make -f
export DH_VERBOSE=1
%:
	dh $@

override_dh_auto_install:
	mkdir -p $$(pwd)/debian/bismark-data-transmit/usr/bin
	mkdir -p $$(pwd)/debian/bismark-data-transmit/etc/init.d
	mkdir -p $$(pwd)/debian/bismark-data-transmit/tmp/bismark-uploads/
	cp $$(pwd)/../bismark-packages/utils/bismark-data-transmit/files/usr/bin/bismark-data-transmit $$(pwd)/debian/bismark-data-transmit/usr/bin
	cp $$(pwd)/../bismark-packages/utils/bismark-data-transmit/files/etc/init.d/bismark-data-transmit $$(pwd)/debian/bismark-data-transmit/etc/init.d
	cp $$(pwd)/bismark-data-transmit debian/bismark-data-transmit/usr/bin/bismark-data-transmit.bin
EOF

chmod +x $TARGETDIR/debian/rules

#$(MAKE) DESTDIR=$$(pwd)/debian/bismark-data-transmit prefix=/usr/bin install

cd $TARGETDIR
debuild -us -uc
#debuild -ai386 -us -uc
cd -

echo END
