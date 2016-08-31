#!/bin/bash

VER=1.0
export DEB_BUILD_OPTIONS=nostrip
TARGETDIR=bismark-active-$VER

#sudo apt-get install libcurl4-openssl-dev
#sudo apt-get install libssl-dev

rm -rf bismark-active
rm -rf $TARGETDIR
git clone https://github.com/projectbismark/bismark-active.git

if [ $1 = "nodownload" ];
 then
    echo "Not checking out/downloading latest code, using existing dir $TARGETDIR..."
 else
    mv bismark-active $TARGETDIR
    cd $TARGETDIR
    git checkout debian
    cd -
fi

tar cvzf bismark-active_$VER.orig.tar.gz $TARGETDIR
mkdir -p $TARGETDIR/debian
mkdir -p $TARGETDIR/debian/source

cat << "EOF" | tee $TARGETDIR/debian/changelog > /dev/null
bismark-active (BISMARKVERSION-1) UNRELEASED; urgency=low

  * Initial release. (Closes: #XXXXXX)

 -- Guilherme Grillo Martins <gmartins@gatech.edu>  Wed, 11 Jun 2014 18:01:56 +0000
EOF

sed -i "s/BISMARKVERSION/$VER/g" $TARGETDIR/debian/changelog

echo "9" > $TARGETDIR/debian/compat

cat << "EOF" | tee $TARGETDIR/debian/control > /dev/null
Source: bismark-active
Maintainer: Guilherme G. Martins <gmartins@gatech.edu>
Section: misc
Priority: optional
Standards-Version: 3.9.4
Build-Depends: debhelper (>= 9)

Package: bismark-active
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}, paris-traceroute, d-itg, dnsutils
Description: BISMark Active Measurements Scripts
 BISMArk Broadband Internet Services beanchMARK

EOF

cat << "EOF" | tee $TARGETDIR/debian/postinst > /dev/null
#!/bin/bash
set -e
if [ -f /etc/init.d/bismark-active ]; then
	chmod +x /etc/init.d/bismark-active
	/etc/init.d/bismark-active start
	update-rc.d -f bismark-active defaults
fi
#DEBHELPER#
EOF


cat << "EOF" | tee $TARGETDIR/debian/postrm > /dev/null
#!/bin/bash
set -e
if [ -x /etc/init.d/bismark-active ]; then
  update-rc.d -f bismark-active remove
fi
rm -f /etc/cron.d/cron-bismark-active
#DEBHELPER#
EOF
chmod +x $TARGETDIR/debian/postrm


#if [ -x /usr/bin/bismark-measure-wrapper ]; then
#	echo "* * * * * root /usr/bin/bismark-measure-wrapper >>/tmp/bismark-scripts.log 2>&1" >/etc/cron.d/cron-bismark-active
#	chmod +x /etc/cron.d/cron-bismark-active
#fi


touch $TARGETDIR/debian/copyright
#echo "$VER lancre" > $TARGETDIR/debian/source/format

cat << "EOF" | tee $TARGETDIR/debian/rules > /dev/null
#!/usr/bin/make -f
export DH_VERBOSE=1
%:
	dh $@

override_dh_auto_install:
	mkdir -p $$(pwd)/debian/bismark-active/etc/init.d/
	mkdir -p $$(pwd)/debian/bismark-active/etc/bismark/
	mkdir -p $$(pwd)/debian/bismark-active/usr/bin/
	cp $$(pwd)/scripts/bismark-* $$(pwd)/debian/bismark-active/usr/bin/
	cp $$(pwd)/etc/bismark-active.conf $$(pwd)/debian/bismark-active/etc/bismark
	cp $$(pwd)/etc/init.d/bismark-active $$(pwd)/debian/bismark-active/etc/init.d/bismark-active
EOF

chmod +x $TARGETDIR/debian/rules

cd $TARGETDIR
debuild -us -uc
#debuild -ai386 -us -uc
cd -

echo END
