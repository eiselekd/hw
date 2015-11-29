
export PATH=`pwd`/build/cross-compiler-armv6l-local/bin:$PATH
rm -rf build/cross-compiler-armv6l-local/bin
mkdir -p build/cross-compiler-armv6l-local/bin
cd build/cross-compiler-armv6l-local/bin;

for f in addr2line ar as c++ c++filt cpp g++ gcc gccbug gcov gprof ld nm objcopy objdump ranlib readelf size strings strip; do
    #ln -sf /proj/pt/ptr3/installs/mvip_20140301/tools/arm-gnu/bin//arm-montavista-linux-gnueabi-${f}  armv6l-${f};
    ln -sf /opt/root-arm/aboriginal-1.4.3/build/native-compiler.sh-armv6l/usr/bin/${f} armv6l-${f};
done

for f in addr2line ar as c++ c++filt cpp g++ gcc gccbug gcov gprof ld nm objcopy objdump ranlib readelf size strings strip; do
    #ln -sf /proj/pt/ptr3/installs/mvip_20140301/tools/arm-gnu/bin//arm-montavista-linux-gnueabi-${f}  armv6l-${f};
    ln -sf /usr/bin/${f} i686-${f};
done

#ln -sf /proj/pt/ptr3/installs/mvip_20140301/tools/arm-gnu/bin//arm-montavista-linux-gnueabi-gcc  armv6l-cc;
#ln -sf /proj/pt/ptr3/installs/mvip_20140301/tools/arm-gnu/bin//arm-montavista-linux-gnueabi-g++  armv6l-c++;
ln -sf /opt/root-arm/aboriginal-1.4.3/build/native-compiler.sh-armv6l/usr/bin/gcc  armv6l-cc;
ln -sf /opt/root-arm/aboriginal-1.4.3/build/native-compiler.sh-armv6l/usr/bin/g++  armv6l-c++;

ln -sf /usr/bin/gcc  i686-cc;
ln -sf /usr/bin/g++  i686-c++;

cd ../../..

