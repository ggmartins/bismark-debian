#!/bin/sh

URL=http://uploads.projectbismark.net/DLB827EB181362/20140718/
URL=http://uploads.projectbismark.net/OW4C60DEE6C732/20140722/
wget $URL

cat index.html | grep -o "active.*gz\"" | sed "s/gz\"/gz/g" > tgzlist

for f in $(cat tgzlist); do

wget -c $URL/$f
tar xvzf $f
cd $(echo $f | sed "s/.tar.gz//g"); mv *.xml ..; cd -
rmdir $(echo $f | sed "s/.tar.gz//g") 
rm $f
done
rm index.html
cat *.xml | grep -o "tool\(id\)\?=\"[a-zA-Z0-9_]\+\"" | sort | uniq -c

