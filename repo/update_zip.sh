#!/usr/bin/env bash

# usage sample: ./update_zip.sh pvr.puzzle.tv 0.0.11

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

zip_file="${repo}/${repo}-${ver}.zip"
md5_file="${zip_file}.md5"

rm -f ${zip_file}
rm -f ${md5_file}

zip -vr "${zip_file}" "${repo}" -x *.git *.gitignore *.DS_Store *.zip*
md5sum "${zip_file}" | cut -d' ' -f1 | tr -d '\n' > "${md5_file}"
