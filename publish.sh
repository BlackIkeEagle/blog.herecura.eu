#!/usr/bin/env sh

hugo
find public -type f -exec chmod u=rw,og=r {} \;
rsync -rlv --delete-after public/ web.herecura.eu:/data/blackikeeagle-blog/data/
rm -rf public
