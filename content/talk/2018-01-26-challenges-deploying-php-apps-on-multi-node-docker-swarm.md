---
title: "Challenges deploying PHP apps on multi node docker swarm"
description: "What challenges do we face deploying php apps on a docker swarm"
date: "2018-01-26"
categories:
    - "linux"
    - "docker"
    - "php"
tags:
    - "PHP"
    - "Docker"
meetuplogo: "/images/logo_phpbnl18.png"
meetupphoto: "/talk/2018-01-26-challenges-deploying-php-apps-on-multi-node-docker-swarm/DUe-VvyX4AA6Axc.jpg"
slides: "/talks/20180126-challenges-deploying-php-apps-on-multi-node-docker-swarm/"
---

How do we get started with docker swarm and how do we get to the point we can
properly deploy and update our php applications. 

Do we need central logging, metrics, alerting to have confidence in our swarm.

<!--more-->

Together with the slides there is a demo swarm setup with working applications.
Warning, the default setup with all apps running will use +12Gb of RAM.

[https://github.com/BlackIkeEagle/alpine-swarm](https://github.com/BlackIkeEagle/alpine-swarm)

There are also 2 sample applications that contain a very simple base approach
to build your own production ready images. Both are using the same approach
where the static files are built into the nginx image and the PHP application
is built into a php-fpm image.

- [https://github.com/BlackIkeEagle/swarm-sample-pimcore](https://github.com/BlackIkeEagle/swarm-sample-pimcore)
- [https://github.com/BlackIkeEagle/swarm-sample-magento2](https://github.com/BlackIkeEagle/swarm-sample-magento2)
