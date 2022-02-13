#!/usr/bin/env sh

hugo
find public -type f -exec chmod u=rw,og=r {} \;
rsync -rlv --delete-after public/ web.herecura.eu:/srv/blackikeeagle-blog/
rm -rf public
