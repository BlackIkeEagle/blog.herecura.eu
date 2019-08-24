---
title: "My browser is not a media player"
description: "My browser, please don't interfere with my media keys"
date: "2019-08-24"
categories:
  - "linux"
  - "media"
tags:
  - "linux"
  - "media"
---

A recent update in Chrome (Blink) based browsers added the functionality to
control media playing via the media buttons on your keyboard. As a side effect
you can also control media on a remote system if you use something like KDE
Connect. But what if you don't want this behaviour and want your media controls
to just control your actual media player?

<!--more-->

## Why enabled by default?

Here I just use chrome because I don't have an existing profile for it. But the
situation is equally true for Vivaldi and Opera (probably other Blink based
browsers too, but did not test those).

So when I go to a website that does media, I can now control the playback of it
via my media controls. I think this is a nice feature, but why is it enabled by
default? And not to be found in the settings? I would rather have this in the
settings than hidden in the flags, this is an intruding feature, which should
not be hidden away this far.

![kdeconnect shows chrome media](kdeconnect.png)

## Turn it off

So I want this turned of in all my browsers. Currently we have to use the flag
[#hardware-media-key-handling](chrome://flags/#hardware-media-key-handling
"Hardware Media Key Handling"). There you can disable the feature.

<video controls="controls" style="width: 100%">
    <source type="video/mp4" src="disable-media-keys.mp4"></source>
    <p>Your browser does not support the video element.</p>
</video>

Now the media controls are off and you can be sure your default media player
will react to your media keys.
