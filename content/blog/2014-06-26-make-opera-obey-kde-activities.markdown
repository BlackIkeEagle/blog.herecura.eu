---
title: "Make Opera obey KDE activities"
date: "2014-06-26"
categories:
    - "Linux"
    - "KDE"
    - "Opera"
tags:
    - "webbrowser"
    - "KDE"
    - "Plasma"
    - "activities"
    - "Linux"
---

## The Problem

When I installed opera-devel on my machine it did not play well with the activities I use in KDE.
Opera was available in all my activities at all the time.

<!--more-->

## There is a simple solution

We need to go to our system settings > window behaviour and add a new window
rule for opera.

![KDE system settings](/blog/2014-06-26-make-opera-obey-kde-activities/system-settings.png)

There is a slight problem, usually KDE is able to detect a Window class (like
the application name). But with Opera it does not find anything.

But no fear, even though the windowtitle changes if you change tabs, at the end
it always adds 'Opera', lets use that.

We add a new windowrule to make sure Opera obeys our activities by 'Window
title > substring > Opera'.

![window matching](/blog/2014-06-26-make-opera-obey-kde-activities/window-matching.png)

Then we need to go to 'Appearance & Fixes' and enable 'Apply initially > no'.

![appearance and fixes](/blog/2014-06-26-make-opera-obey-kde-activities/appearance-and-fixes.png)

And now opera is behaving just fine with KDE activities.
