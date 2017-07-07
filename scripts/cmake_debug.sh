#!/bin/sh

set -e

if [ $# -eq 0 ]; then
echo "No arguments supplied"
exit
fi

if [ -z "$1" ]; then
echo "No repo argument supplied"
exit
fi

if [ -z "$2" ]; then
echo "No version argument supplied"
exit
fi

if [ -z "$3" ]; then
echo "No kodi path argument supplied"
exit
fi


KODI_ROOT="$PWD/$3"
echo KODI-ROOT=$KODI_ROOT

ADDON_VER=$2
echo ADDON_VER=$ADDON_VER

ADDON_NAME=$1
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
cmake -DADDONS_TO_BUILD=$ADDON_NAME -DADDON_SRC_PREFIX=../.. -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=$KODI_ROOT/addons -DPACKAGE_ZIP=1 $KODI_ROOT/project/cmake/addons
make
make package-addons

echo Coping to build directory...
cp -fv "$ADDON_NAME-prefix/src/$ADDON_NAME-build/addon-$ADDON_NAME-$ADDON_VER.zip" "."
echo Done.

