#!/usr/bin/env sh

hugo
find public -type f -exec chmod u=rw,og=r {} \;
rsync -rlv --delete-after public/ herecura.eu:/var/lib/blackikeeagle-blog/data/
rm -rf public
