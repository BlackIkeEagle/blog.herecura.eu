#!/usr/bin/env sh

git subtree pull --prefix themes/hyde https://github.com/spf13/hyde.git master --squash
git subtree pull --prefix themes/hugo-notice https://github.com/martignoni/hugo-notice.git main --squash
git subtree pull --prefix themes/hugo-video https://github.com/martignoni/hugo-video.git master --squash
