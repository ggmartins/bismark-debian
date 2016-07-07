#!/bin/bash

if [ ! -d bismark-packages ]; then
  git clone https://github.com/projectbismark/bismark-packages.git
fi

TARGETDIR=shaperprobe-2009.10
#export DEB_BUILD_OPTIONS=nostrip
rm -rf $TARGETDIR
cp bismark-packages/net/shaperprobe/src/ $TARGETDIR -r

tar cvzf $TARGETDIR.orig.tar.gz $TARGETDIR
mkdir -p $TARGETDIR/debian

cat << "EOF" | tee $TARGETDIR/debian/changelog > /dev/null
bismark-shaperprobe (2009.10) UNRELEASED; urgency=low

  * Initial release. (Closes: #XXXXXX)

 -- Guilherme Grillo Martins <gmartins@gatech.edu>  Wed, 11 Jun 2014 18:01:56 +0000
EOF

echo "9" > $TARGETDIR/debian/compat

cat << "EOF" | tee $TARGETDIR/debian/control > /dev/null
Source: bismark-shaperprobe
Maintainer: Guilherme G. Martins <gmartins@gatech.edu>
Section: misc
Priority: optional
Standards-Version: 3.9.4
Build-Depends: debhelper (>= 9)

Package: bismark-shaperprobe
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}
Replaces: netcat-traditional
Conflicts: netcat-traditional
Description: BISMark shaperProbe
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

override_dh_auto_install:
	mkdir -p $$(pwd)/debian/bismark-shaperprobe/usr/bin
	cp $$(pwd)/prober debian/bismark-shaperprobe/usr/bin/prober
EOF

chmod +x $TARGETDIR/debian/rules

cd $TARGETDIR
debuild -us -uc
#debuild -ai386 -us -uc
cd -

#for f in $(ls  bismark-_*.deb 2>/dev/null); do
# mkdir deb_tmp
# dpkg-deb -x $f deb_tmp
# dpkg-deb --control $f deb_tmp/DEBIAN
# cd deb_tmp;rm -f usr/share/info/dir.gz;cd -
# dpkg -b deb_tmp $f
# rm -rf deb_tmp
#done

echo END
