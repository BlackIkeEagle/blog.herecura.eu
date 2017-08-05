#!/usr/bin/env sh

hugo
rsync -av --delete-after public/ herecura.eu:/var/lib/blackikeeagle-blog/data/
rm -rf public
