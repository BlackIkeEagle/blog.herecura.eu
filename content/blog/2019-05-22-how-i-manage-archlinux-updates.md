---
title: "How I manage Arch Linux updates"
description: "My way of updating my Arch Linux installations"
date: "2019-05-22"
categories:
  - "Arch Linux"
  - "linux"
tags:
  - "linux"
---

## My goals

I want to be able to update my machine at any time without having to waste a
lot of time waiting for stuff to download. Over the years I've had my fair
share of small issues occuring when doing an update on a system running a
"desktop". So for a few years now I do my updates when logged out of a
"desktop" in a tty.

<!--more-->

## Download latest packges locally

I usually use 2 distinct steps to update any of my machines.

1st: download the latest packages available for update.

``` sh
$ sudo pacman -Syuw
```

I can do this manually while still working on the machine.

## Update

Whenever I see fit I will run the actual update. I'm not updating every day, so
a kernel update or another system critical package update is not uncommon in
this case. Once I have decided I will do an update I close everything. I logout
of my "desktop" and switch to tty2 (ctrl + alt + 2).

I login on the tty and run the following:

``` sh
$ sudo pacman -Su
$ sudo pacdiff
$ reboot
```

## Bonus: automatic download of updated packages

For my personal desktop and my work laptop, I know they will be running at
noon, but usually between 12h30 and 13h00 I will be eating. For this I have
added a systemd timer that will trigger updated pacakges downloads at 12h30. So
I know the machine will be running and I'm probably doing nothing with it at
that time.

Just add 2 small files in `/etc/systemd/system`.

1 - `/etc/systemd/system/download-updates.service`

```
[Unit]
Description=download package updates

[Service]
Type=simple
ExecStart=/usr/bin/pacman -Syuw --noconfirm
```

The service file has no 'install' section, because it just needs to be
triggered by the timer, nothing else.

2 - `/etc/systemd/system/download-updates.timer`

```
[Unit]
Description=download updates for install

[Timer]
OnCalendar=Mon..Fri 12:30

[Install]
WantedBy=timers.target
```

This will do nothing yet. If we list the timers, no download updates there.

``` sh
$ sudo systemctl list-timers                                           
NEXT                          LEFT          LAST                          PASSED       UNIT                         ACTIVATES
Thu 2019-05-23 00:00:00 CEST  2h 13min left Wed 2019-05-22 10:22:37 CEST  11h ago      logrotate.timer              logrotate.service
Thu 2019-05-23 00:00:00 CEST  2h 13min left Wed 2019-05-22 10:22:37 CEST  11h ago      man-db.timer                 man-db.service
Thu 2019-05-23 00:00:00 CEST  2h 13min left Wed 2019-05-22 10:22:37 CEST  11h ago      shadow.timer                 shadow.service
Thu 2019-05-23 19:31:27 CEST  21h left      Wed 2019-05-22 16:49:09 CEST  4h 57min ago systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service

4 timers listed.
Pass --all to see loaded but inactive timers, too.
```

So just enable the new timer and your machine will download the latest package
updates every workday at 12h30.

``` sh
$ sudo systemctl enable download-updates.timer
```

To check if the new timer is there list 'all' timers

``` sh
$ sudo systemctl list-timers --all
NEXT                          LEFT         LAST                          PASSED      UNIT                         ACTIVATES
Thu 2019-05-23 00:00:00 CEST  2h 9min left Wed 2019-05-22 10:22:37 CEST  11h ago     logrotate.timer              logrotate.service
Thu 2019-05-23 00:00:00 CEST  2h 9min left Wed 2019-05-22 10:22:37 CEST  11h ago     man-db.timer                 man-db.service
Thu 2019-05-23 00:00:00 CEST  2h 9min left Wed 2019-05-22 10:22:37 CEST  11h ago     shadow.timer                 shadow.service
Thu 2019-05-23 19:31:27 CEST  21h left     Wed 2019-05-22 16:49:09 CEST  5h 1min ago systemd-tmpfiles-clean.timer systemd-tmpfiles-clean.service
n/a                           n/a          n/a                           n/a         download-updates.timer       download-updates.service

5 timers listed.
```

Voila, there it is, no more worrying about downloading, just run the update
whenever it fits.

## Closing

This is my preferred way of updating my Arch Linux machines. You should not
feel obliged to do it this way. It just works great for me.

