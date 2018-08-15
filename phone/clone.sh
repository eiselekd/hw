# https://wiki.lineageos.org/devices/jfltexx/build
d=`pwd`
mkdir -p ~/bin
mkdir -p ~/android/lineage
curl https://storage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
chmod a+x ~/bin/repo
cat <<EOF >>~/.bashrc
# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi
EOF

cd ~/android/lineage
repo init -u https://github.com/LineageOS/android.git -b cm-14.1
repo sync

$d/extract.sh $d ~/android/lineage/device/samsung/jfltexx

source build/envsetup.sh
breakfast jfltexx

export ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4G"
export LC_ALL=C.UTF-8

croot
brunch jfltexx
