#!/bin/sh

set -e

KODI_ROOT="/Code/Other/Kodi-PVR"
echo KODI-ROOT=$KODI_ROOT

ADDON_NAME="pvr.puzzle.tv"
KODI_CMAKE_ADDON="$KODI_ROOT/project/cmake/addons/addons/$ADDON_NAME"
echo KODI_CMAKE_ADDON=$KODI_CMAKE_ADDON

rm -rf $KODI_CMAKE_ADDON
mkdir -p "$KODI_CMAKE_ADDON"
echo all >$KODI_CMAKE_ADDON/platforms.txt
echo $ADDON_NAME https://github.com/srg70/$ADDON_NAME master > $KODI_CMAKE_ADDON/$ADDON_NAME.txt


rm -f $ADDON_NAME/$ADDON_NAME/addon.xml
rm -rf $ADDON_NAME/build
mkdir $ADDON_NAME/build
cd $ADDON_NAME/build
echo  PWD BEFORE CMAKE= $PWD
cmake -DADDONS_TO_BUILD=$ADDON_NAME -DADDON_SRC_PREFIX=../.. -DCMAKE_BUILD_TYPE=Debug -DCMAKE_INSTALL_PREFIX=$KODI_ROOT/addons -DPACKAGE_ZIP=1 $KODI_ROOT/project/cmake/addons
make
echo Done.

