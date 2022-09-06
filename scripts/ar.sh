#!/bin/sh

for file in *.deb;
do
ar x $file
unzstd control.tar.zst
unzstd data.tar.zst
xz control.tar
xz data.tar
rm $file
ar cr $file debian-binary control.tar.xz data.tar.xz
rm control.tar.zst
rm data.tar.zst
rm control.tar.xz
rm data.tar.xz
rm debian-binary
done
