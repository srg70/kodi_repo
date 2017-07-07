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
echo "No platform argument supplied"
exit
fi

repo="$1"
ver="$2"
platform="$3"
pwd
echo $repo-$ver-$platform

KODI_ROOT="xbmc"
echo KODI-ROOT=$KODI_ROOT

if [ ! -d $KODI_ROOT ]; then
    git clone https://github.com/xbmc/xbmc.git
    cd xbmc
    git checkout tags/17.1-Krypton
    cd ..
fi
if [ ! -d "$repo" ]; then
#rm -rf pvr.puzzle.tv
    echo Cloning $repo ...
    git clone https://github.com/srg70/pvr.puzzle.tv.git
    cd $repo
    git checkout
    cd ..
fi

# OSX - native build
if [ "$platform" = "osx" ]; then
    ./cmake.sh $repo $ver $KODI_ROOT
fi

#linux-x64
if [ "$platform" = "linux-x64" ]; then
    docker run --rm dockcross/linux-x64 > ./dockcross-linux-x64
    chmod +x ./dockcross-linux-x64
    ./dockcross-linux-x64 bash -c "./cmake.sh $repo $ver $KODI_ROOT"
fi

#linux-x86
if [ "$platform" = "linux-x86" ]; then
docker run --rm dockcross/linux-x86 > ./dockcross-linux-x86
chmod +x ./dockcross-linux-x86
./dockcross-linux-x64 bash -c "./cmake.sh $repo $ver $KODI_ROOT"
fi

#android-arm
if [ "$platform" = "android-arm" ]; then
    docker run --rm dockcross/android-arm > ./dockcross-android-arm
    chmod +x ./dockcross-android-arm
    ./dockcross-android-arm bash -c "./cmake.sh $repo $ver $KODI_ROOT"
fi

#windows-x86
if [ "$platform" = "windows-x86" ]; then
    echo 'Windows platform can be build only natively for now.' ;
    exit 1;
#    docker run --rm dockcross/windows-x86 > ./dockcross-windows-x86
#    chmod +x ./dockcross-windows-x86
#    ./dockcross-windows-x86 bash -c "./cmake.sh $repo $ver $KODI_ROOT"
fi

#linux-armv6
if [ "$platform" = "linux-armv6" ]; then
docker run --rm dockcross/linux-armv6 > ./dockcross-linux-armv6
chmod +x ./dockcross-linux-armv6
./dockcross-linux-armv6 bash -c "./cmake.sh $repo $ver $KODI_ROOT"
fi

#linux-armv7
if [ "$platform" = "linux-armv7" ]; then
docker run --rm dockcross/linux-armv7 > ./dockcross-linux-armv7
chmod +x ./dockcross-linux-armv7
./dockcross-linux-armv7 bash -c "./cmake.sh $repo $ver $KODI_ROOT"
fi

#linux-arm64
if [ "$platform" = "linux-arm64" ]; then
docker run --rm dockcross/linux-arm64 > ./dockcross-linux-arm64
chmod +x ./dockcross-linux-arm64
./dockcross-linux-arm64 bash -c "./cmake.sh $repo $ver $KODI_ROOT"
fi

#./cmake.sh "$KODI_ROOT"
