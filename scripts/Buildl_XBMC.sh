#!/bin/sh

#  Install_XBMC.sh
#  XBMC
#
#  Created by Sergey Shramchenko on 10/15/13.
#
set -e

XBMC_HOME=/Code/Git/Kodi-iOS
#rm -rf /Users/Shared/xbmc-depends
echo
echo "***********************"
echo "*    C L E A N U P                 "
echo "***********************"
echo

cd $XBMC_HOME
git clean -xfd

echo
echo "***********************"
echo "*          D E P S                 "
echo "***********************"
echo

cd "$XBMC_HOME/tools/depends"
./bootstrap

echo
echo "***********************"
echo "*     D E P S (configure)     "
echo "***********************"
echo

#./configure --host=x86_64-apple-darwin
./configure --host=arm-apple-darwin --with-cpu=arm64 --with-platform=tvos --with-sdk=11.4
# cp /usr/bin/m4 /Users/Shared/xbmc-depends/buildtools-native/bin

echo
echo "***********************"
echo "*       D E P S (make)        "
echo "***********************"
echo

if make -j$(getconf _NPROCESSORS_ONLN); then
    echo "***********************"
    echo "*    D E P S (make) DONE     "
    echo "***********************"
else
    echo "************************"
    echo "*    D E P S (make) FAILED    "
    echo "*    R E B U I L D (native m4) "
    echo "************************"
    cp /usr/bin/m4 /Users/Shared/xbmc-depends/buildtools-native/bin
    make -j$(getconf _NPROCESSORS_ONLN)
fi

echo "*********************"
echo "*   BIN ADDONS (make)   "
echo "*********************"
make -j$(getconf _NPROCESSORS_ONLN) -C target/binary-addons

echo
echo "***********************"
echo "*         X B M C                  "
echo "***********************"
echo

# Before v18
cd "$XBMC_HOME"
make -j$(getconf _NPROCESSORS_ONLN) -C tools/depends/target/xbmc
make clean
make -j$(getconf _NPROCESSORS_ONLN) xcode_depends

#From v18
#cd $XBMC_HOME/build
#/Users/Shared/xbmc-depends/x86_64-darwin17.2.0-native/bin/cmake -G Xcode -DCMAKE_TOOLCHAIN_FILE=/Users/Shared/xbmc-depends/macosx10.13_x86_64-target-debug/share/Toolchain.cmake ..
#


