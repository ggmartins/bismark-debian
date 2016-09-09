#4!/bin/bash

if [ ! -f netperf_2.4.4.orig.tar.gz ]; then
  #really ? gtisc url?
  wget -c http://ftp.de.debian.org/debian/pool/non-free/n/netperf/netperf_2.4.4.orig.tar.gz
fi

#export DEB_BUILD_OPTIONS=nostrip

tar xvzf netperf_2.4.4.orig.tar.gz
mv netperf_2.4.4.orig bismark-netperf_2.4.4.orig
patch -p0 bismark-netperf_2.4.4.orig/src/netlib.c < bismark-netperf.patches/netlib.patch
patch -p0 bismark-netperf_2.4.4.orig/src/netsh.c < bismark-netperf.patches/netsh.patch
patch -p0 bismark-netperf_2.4.4.orig/src/nettest_bsd.c < bismark-netperf.patches/nettest_bsd.patch
tar cvzf bismark-netperf_2.4.4.orig.tar.gz bismark-netperf_2.4.4.orig

TARGETDIR=bismark-netperf_2.4.4.orig

cp config.guess $TARGETDIR/
cp config.sub $TARGETDIR/

mkdir -p $TARGETDIR/debian

cat << "EOF" | tee $TARGETDIR/debian/changelog > /dev/null
bismark-netperf (2.4.4-1) UNRELEASED; urgency=low

  * Initial release. (Closes: #XXXXXX)

 -- Guilherme Grillo Martins <gmartins@gatech.edu>  Wed, 11 Jun 2014 18:01:56 +0000
EOF

echo "9" > $TARGETDIR/debian/compat

cat << "EOF" | tee $TARGETDIR/debian/control > /dev/null
Source: bismark-netperf
Maintainer: Guilherme G. Martins <gmartins@gatech.edu>
Section: misc
Priority: optional
Standards-Version: 3.9.4
Build-Depends: debhelper (>= 9)

Package: bismark-netperf
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: BISmark NetPerf
 BISMArk Broadband Internet Services beanchMARK

EOF


touch $TARGETDIR/debian/copyright
mkdir -p $TARGETDIR/debian/source/
#echo "1.0 lancre" > $TARGETDIR/debian/source/format
#sed "s/#define HAVE_SCHED_SETAFFINITY 1/\/\/#define HAVE_SCHED_SETAFFINITY 1/g" -i config.h
cat << "EOF" | tee $TARGETDIR/debian/rules > /dev/null
#!/usr/bin/make -f
export DH_VERBOSE=1
%:
	dh $@

override_dh_auto_configure:
	dh_auto_configure
	sed "s/#define HAVE_SCHED_SETAFFINITY 1/\/\/#define HAVE_SCHED_SETAFFINITY 1/g" -i $$(pwd)/config.h

override_dh_auto_install:
	dh_auto_install
EOF

	#imkdir -p $$(pwd)/debian/bismark-dropbear/etc/dropbear
	#cp $$(pwd)/debian/authorized_keys $$(pwd)/debian/bismark-dropbear/etc/dropbear
chmod +x $TARGETDIR/debian/rules

cd $TARGETDIR
debuild -us -uc
#debuild -ai386 -us -uc
cd -

for f in $(ls bismark-netperf_2.4.4-1_*.deb 2>/dev/null); do
 mkdir deb_tmp
 dpkg-deb -x $f deb_tmp
 dpkg-deb --control $f deb_tmp/DEBIAN
 cd deb_tmp;rm -f usr/share/info/dir.gz;cd -
 dpkg -b deb_tmp $f
 rm -rf deb_tmp
done

echo END
