#!/bin/bash

for f in $(git diff --name-only);
do
git diff $f > $(echo $f | sed 's/\//\_/g').patch

done

#for i in `ls  scripts_*`; do echo `echo $i |sed 's/\_/\//g'` | sed 's/\.patch//g';done