#!/bin/bash


#export DEB_BUILD_OPTIONS=nostrip
TARGETDIR=netcat-0.7.1

rm -rf $TARGETDIR
tar xvzf $TARGETDIR.tar.gz 

tar cvzf bismark-netcat-gnu_0.7.1.orig.tar.gz $TARGETDIR
mkdir -p $TARGETDIR/debian

cat << "EOF" | tee $TARGETDIR/debian/changelog > /dev/null
bismark-netcat-gnu (0.7.1-1) UNRELEASED; urgency=low

  * Initial release. (Closes: #XXXXXX)

 -- Guilherme Grillo Martins <gmartins@cc.gatech.edu>  Wed, 11 Jun 2014 18:01:56 +0000
EOF

echo "9" > $TARGETDIR/debian/compat

cat << "EOF" | tee $TARGETDIR/debian/control > /dev/null
Source: bismark-netcat-gnu
Maintainer: Guilherme G. Martins <gmartins@cc.gatech.edu>
Section: misc
Priority: optional
Standards-Version: 3.9.4
Build-Depends: debhelper (>= 9)

Package: bismark-netcat-gnu
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: BISmark NetCat GNU
 BISMArk Broadband Internet Services beanchMARK

EOF


touch $TARGETDIR/debian/copyright
mkdir -p $TARGETDIR/debian/source/
#echo "1.0 lancre" > $TARGETDIR/debian/source/format

cat << "EOF" | tee $TARGETDIR/debian/rules > /dev/null
#!/usr/bin/make -f
export DH_VERBOSE=1
%:
	dh $@

#override_dh_auto_install:
	#mkdir -p $$(pwd)/debian/bismark-data-transmit/usr/bin
	#cp $$(pwd)/bismark-data-transmit debian/bismark-data-transmit/usr/bin/bismark-data-transmit.bin
EOF

chmod +x $TARGETDIR/debian/rules

cd $TARGETDIR
debuild -us -uc
#debuild -ai386 -us -uc
cd -

echo END
