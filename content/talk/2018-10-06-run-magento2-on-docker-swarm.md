---
title: "Run Magento 2 on Docker swarm"
description: "Setup your swarm and run magento2 on it"
date: "2018-10-06"
categories:
    - "docker"
    - "swarm"
    - "php"
    - "magento2"
tags:
    - "Docker"
    - "Swarm"
    - "Magento 2"
meetuplogo: "/images/logo_mage-titans.png"
meetupphoto: "/talk/2018-10-06-run-magento2-on-docker-swarm/Do0kXZbXkAEqlND.jpg"
slides: "/talks/20181006-run-magento2-on-docker-swarm/run-magento-on-docker-swarm-2018-10-06-magetitans-nl.pdf"
---

When you are already developing your Magento 2 application using Docker, it
would nice to be able to deploy it using Docker.

<!--more-->

We'll start from our application in development and take the following steps to
end up on production. We will build custom images with our application embedded
and we might need some extra steps (like data migrations, ...). On a production
environment we also want to be able to see our logs quickly and easily, so we
need a solution for that. And then we also have to deal with shared data, how
can we make sure if you for example upload an image that it will be available
for all running containers.

We'll end up with a simple way to use docker from development all the way to
production.
