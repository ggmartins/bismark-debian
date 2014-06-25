#!/bin/bash

VER=1.0
export DEB_BUILD_OPTIONS=nostrip
TARGETDIR=bismark-active-$VER

rm -rf bismark-active
rm -rf $TARGETDIR
rm -rf bismark-packages
git clone https://github.com/projectbismark/bismark-active.git


mv bismark-active $TARGETDIR
cd $TARGETDIR
cp ../gitpatches.tgz .
tar xvzf gitpatches.tgz
rm gitpatches.tgz
for i in `ls  scripts_*`; do patch -p0 $(echo `echo $i |sed 's/\_/\//g'` | sed 's/\.patch//g') < $i ;done
rm -f *.patch
#git checkout debian
cd -


tar cvzf bismark-active_$VER.orig.tar.gz $TARGETDIR
mkdir -p $TARGETDIR/debian

cat << "EOF" | tee $TARGETDIR/debian/changelog > /dev/null
bismark-active (BISMARKVERSION-1) UNRELEASED; urgency=low

  * Initial release. (Closes: #XXXXXX)

 -- Guilherme Grillo Martins <gmartins@cc.gatech.edu>  Wed, 11 Jun 2014 18:01:56 +0000
EOF

sed -i "s/BISMARKVERSION/$VER/g" $TARGETDIR/debian/changelog

echo "9" > $TARGETDIR/debian/compat

cat << "EOF" | tee $TARGETDIR/debian/control > /dev/null
Source: bismark-active
Maintainer: Guilherme G. Martins <gmartins@cc.gatech.edu>
Section: misc
Priority: optional
Standards-Version: 3.9.4
Build-Depends: debhelper (>= 9)

Package: bismark-active
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}, netperf, paris-traceroute, d-itg, dnsutils
Description: BISMark Active Measurements Scripts
 BISMArk Broadband Internet Services beanchMARK

EOF

cat << "EOF" | tee $TARGETDIR/debian/postinst > /dev/null
#!/bin/bash

if [ -x /usr/bin/bismark-measure-wrapper ]; then
	echo "* * * * * root /usr/bin/bismark-measure-wrapper >>/tmp/bismark/scripts.log 2>&1" >/etc/cron.d/cron-bismark-active
	chmod +x /etc/cron.d/cron-bismark-active
fi

EOF

touch $TARGETDIR/debian/copyright
echo "$VER lancre" > $TARGETDIR/debian/source/format

cat << "EOF" | tee $TARGETDIR/debian/rules > /dev/null
#!/usr/bin/make -f
export DH_VERBOSE=1
%:
	dh $@

override_dh_auto_install:
	mkdir -p $$(pwd)/debian/bismark-active/etc/bismark/
	mkdir -p $$(pwd)/debian/bismark-active/usr/bin/
	cp $$(pwd)/scripts/bismark-* $$(pwd)/debian/bismark-active/usr/bin/
	cp $$(pwd)/etc/bismark-active.conf $$(pwd)/debian/bismark-active/etc/bismark
EOF

chmod +x $TARGETDIR/debian/rules

cd $TARGETDIR
debuild -us -uc
debuild -ai386 -us -uc
cd -

echo END
