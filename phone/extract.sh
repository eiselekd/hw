#!/bin/sh
# https://wiki.lineageos.org/extracting_blobs_from_zips.html

mkdir ~/android/system_dump/
cd ~/android/system_dump/
unzip $1/lineage-*.zip system.transfer.list system.new.dat

git clone https://github.com/xpirt/sdat2img
python sdat2img/sdat2img.py system.transfer.list system.new.dat system.img

mkdir system/
sudo mount system.img system/

(
    cd $2;
    ./extract-files.sh ~/android/system_dump/
)

sudo umount ~/android/system_dump/system


