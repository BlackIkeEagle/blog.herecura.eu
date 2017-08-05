---
title: "Isolating multiple PHP versions / apps with docker"
description: "use docker to provide a optimized environment for specific apps"
date: "2014-10-07"
categories:
    - "docker"
    - "php"
tags:
    - "Docker"
    - "PHP"
meetuplogo: "/images/logo_phpwvl.jpeg"
meetupphoto: "/talk/2014-10-07-isolating-multiple-php-versions-apps-with-docker/highres_418900122.jpeg"
slides: "/talks/20141007-php-wvl_isolating-multiple-php-versions-apps-with-docker/"
---

Chroot? what is that? Is docker a chroot?

With docker / containers we can easily isolate our PHP applications from the
host system. It also helps us running multiple PHP versions without too much
hassle. As an extra bonus our specific application containers can have their
own extensions without interfering with each other.

With nginx as webserver we will show some of the handy features of docker.
