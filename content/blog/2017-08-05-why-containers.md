---
title: "Why I like containers for everything"
date: "2017-08-05"
categories:
    - "webdevelopment"
    - "linux"
    - "docker"
tags:
    - "Linux"
    - "Docker"
    - "development"
---

I want to explain why running everything in containers is an improvement over
install all your required software on a server. How containers can help us
build better quality software faster.

<!--more-->

## The question

A short while ago a colleague asked me "why did you setup that project with
docker?".  All I could say was "its simple and easy". My colleague replied
"yeah but just setting up all the required software on the server is also
easy, so whats the benefit". I could not answer. I just like containers and
for me, setting them up and using them feels straight forward. But is it so
straight forward for others and am I not just forcing my pet projects on my
colleagues because I like this approach and they just have to follow along.
This got me thinking.  What are the benefits of using containers over the
traditional - install all your required software on the server and be done
with it - approach.

## Software consistency from development to production

This is one of the main benefits already, the versions we use in development
are the exact same versions that will be used on production. When we were on
the traditional approach we usually had differences between what we were
running in our development VM versus what was running on the target production
server. We also frequently had differences between how the development machine
was configured versus what the configuration was on a production machine. Se we
could end up with problems in production that were not reproducible in
development. When we run all our stuff in containers we avoid this type of
issues. The stack in development and in production is exactly the same.

## Easy updates flowing from development to production

When we have updates in our underlying software stack, we first get those
updates in the containers we use in development. If we would have
inconsistencies or encounter problems causing our software to break in major
ways we can quickly go back to the previous stack, and no harm done. This also
means we already have been running on the 'new' stack for a while in different
development setups and a staging environment which will give us big certainty
the stack will not cause any problems in production. This type of consistency
we never had with the development VM approach.

## Use the software version that suits your needs

We use Ubuntu as host for all our servers. Our hosting company chooses to
follow the LTS versions and when a new server is installed you get the latest
available LTS version. In some case we want to use different versions than the
ones available in the repositories of the distribution. That is where
containers come into play. You can use the version of a certain piece of
software that suits your project without the potential to completely fuck up
your server as we occasionally had when we were using some PPA to suit our
software's need.

## Setup speed

Using something that is already fully configured and installed is a lot faster
than having to setup a new VM and provision that VM. We already tackled that
problem a bit by using pre-provisioned VM's, but that reduced the ease to keep
up with some other updates.

## Ease of deployment

Have to setup a new environment? Easy, just start a new set of containers
on the same or other hardware you already have running. This allows for
flexible and disposable one-time-needed environments to test for example a new
feature that needs feedback and because of that is not yet merged in your main
branches.

## Allows easier and more automation

Because of the extra flexibility building and running software in containers
allows us to automate a lot of processes a lot easier. Especially when we start
talking about disposable environments and one-shot environment that have a
short lifetime for a very specific purpose.

## Conclusion

What makes containers more useful to me and better than just install the
software on the server and be done with it, is the following: consistency
across all environments, ease of choosing the software (version) that suits
your needs, the flexibility given to have disposable environments without much
overhead. In the end its the flexibility that appeals to me.
