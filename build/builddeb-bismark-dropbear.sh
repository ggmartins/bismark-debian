#!/bin/bash

#export DEB_BUILD_OPTIONS=nostrip
TARGETDIR=dropbear-2011.54

rm -rf $TARGETDIR
tar xvzf $TARGETDIR.tar.gz 

tar xvzf bismark-dropbear.patches.tgz

cd $TARGETDIR
for i in `ls ../bismark-dropbear.patches`; do
  patchfile=../bismark-dropbear.patches/$i
  patchee=$(cat $patchfile | grep "\-\-\- a" | sed "s/--- a\///g")
  if [ -n "${patchee}" ]; then
    patch -p0 $patchee < $patchfile
  fi
done
cd -

tar cvzf bismark-dropbear_2011.54.orig.tar.gz $TARGETDIR
mkdir -p $TARGETDIR/debian

cat << "EOF" | tee $TARGETDIR/debian/authorized_keys > /dev/null
ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCpx7OYofKSxKnmPtEshGYwbcM7UqxO+a/MTJj0MWy2GDI/x7nT3RYuiIMROYf/9DOnWOAirToibwMB697wkde3Q9wtk4ReCINY1W1lYLCxlGQweRkuIst4p/pwBMrAqarrJgyKJXFiXUpLOuymOS5+68y9SgYhpnLotK1+ZY/y4Ch/D7/iJ8oQVErzdOk7pePWxs2KB5/5QU8fy2BTBp+gNK7SalShlzDsB9iZyF0eMe1SCgp80tIexE9RzWl3OXbmvoJU6pv3mw4+2Tn+EavxHepCGI8LgzGduMruH+UZnZuG/2mTM2EEL1WBzOit3rco4Hev6KI+OYcJSRv9ZiC6B3WxQiIwKk9DHwE4uq4wBRaCTkvnrYKAXrHbwM28U5fzr+Tl0NsNCp8FntMN0yy5DfnyTRY2B7T3fWQ6TpJ99AxK8trDLb0v5L61IjIvSBLBTyqxIa4jQAqxQLoI8O6/uCiwPLKzQHzIvFdtWo5w0cTXSsW5Bhj4cxd/3OQR1TNT0b9xh0WtSbltMdeaqyi1iEsSTVveOrAOWhWGj2do8xIOn1+gZ9mcllZH5Nc/yiFFCqQsgSkQnk8lVAyeRxCABD4G55o0zcInOxZJn2oVoXoQiAXmhWX52A0BKa3Z47c28n+imZX+IDnvKqXO3yxvi8ak3Ey+qtqUgRLTSL3h3w== bismark@dp4
EOF

cat << "EOF" | tee $TARGETDIR/debian/changelog > /dev/null
bismark-dropbear (2011.54-1) UNRELEASED; urgency=low

  * Initial release. (Closes: #XXXXXX)

 -- Guilherme Grillo Martins <gmartins@cc.gatech.edu>  Wed, 11 Jun 2014 18:01:56 +0000
EOF

echo "9" > $TARGETDIR/debian/compat

cat << "EOF" | tee $TARGETDIR/debian/control > /dev/null
Source: bismark-dropbear
Maintainer: Guilherme G. Martins <gmartins@cc.gatech.edu>
Section: misc
Priority: optional
Standards-Version: 3.9.4
Build-Depends: debhelper (>= 9)

Package: bismark-dropbear
Architecture: any
Depends: ${shlibs:Depends}, ${misc:Depends}
Description: BISmark DropBear SSH
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
	mkdir -p $$(pwd)/debian/bismark-dropbear/etc/dropbear
	cp $$(pwd)/debian/authorized_keys $$(pwd)/debian/bismark-dropbear/etc/dropbear
	dh_auto_install
EOF

chmod +x $TARGETDIR/debian/rules

cd $TARGETDIR
debuild -us -uc
#debuild -ai386 -us -uc
cd -

echo END
