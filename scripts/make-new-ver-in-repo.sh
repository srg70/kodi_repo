#!/usr/bin/env bash

# usage sample: ./make-new-ver-in-repo.sh pvr.puzzle.tv 0.0.11

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

repo="$1"
ver="$2"

echo $repo-$ver
do_git="YES"

#cmake_sh="$PWD/cmake.sh"

#------------------------- Bump Version ----------------------------------
cd $repo

pwd

if [ "$do_git" = "YES" ]; then
git reset --hard HEAD
git pull
fi
cd $repo

perl -pi -e "s,[\"']${repo}[\"'](.+)version=[\"'](.+?)[\"'],\"${repo}\"\1version=\"${ver}\"," "addon.xml.in"

cd ..
#if [ ! -z "$3" ]; then
#	changes="$3"
#	../chlogadd.sh $ver "$changes"
#	git add "changelog.txt"
#fi

if [ "$do_git" = "YES" ]; then
#git add "$repo/addon.xml"
git add "$repo/addon.xml.in"
    git commit  --author="Sergey Shramchenko <sergey.shramchenko@gmail.com>" -m "Bump V${ver}"
    git tag "V${ver}"
    git push
fi

cd ..

#------------------------ Build for platforms  ----------------------------------------
#windows-x86
#for platform in osx linux-x64 android-arm linux-armv7 linux-x86 linux-arm64; do
for platform in android-arm; do

    echo "Start build for $platform"
    ./run_doccross.sh $repo $ver $platform
    echo "Done build for $platform"

    #zip -r "kodi_repo/repo/${repo}/${repo}-${ver}.zip" "${repo}" -x .git .gitignore
    #cd "${repo}"

    zip_in="${repo}/build/addon-${repo}-${ver}.zip"
    zip_out="kodi_repo/repo/${platform}/${repo}/${repo}-${ver}.zip"
    #git archive --format=zip -v --output="${zip_out}" HEAD --prefix=${repo}/

    #cd ..
    platfrom_repo="kodi_repo/repo/${platform}/${repo}/"
    test -d "$platfrom_repo" || mkdir -p "$platfrom_repo"
    cp -fv ${repo}/${repo}/addon.xml "$platfrom_repo"
    cp -fv $zip_in $zip_out
    md5sum "${zip_out}" | cut -d' ' -f1 | tr -d '\n' > "${zip_out}.md5"

    cd "kodi_repo/repo/${platform}"
    python '@generate.py'
    cd ../..

    if [ "$do_git" = "YES" ]; then
        git add "repo/${platform}/addons.*"
        git add "repo/${platform}/${repo}"
fi
    cd ..
done
#--------------------------------------------------------------------------------

cd "kodi_repo"
#
#python '@generate.py'
#
#git add addons.*
#git add ${repo}

if [ "$do_git" = "YES" ]; then
git commit  --author="Sergey Shramchenko <sergey.shramchenko@gmail.com>" -m "$repo-$ver"
git push
fi

cd ..

