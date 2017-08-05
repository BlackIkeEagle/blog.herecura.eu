---
title: "Handling signals in PHP"
description: "How do we properly handle signals sent to your php script/app"
date: "2015-03-24"
categories:
    - "signals"
    - "posix"
    - "php"
tags:
    - "Posix"
    - "PHP"
meetuplogo: "/images/logo_phpwvl.jpeg"
meetupphoto: "/talk/2015-03-24-handling-signals-in-php/highres_435879231.jpeg"
slides: "/talks/20150324-handling-signals-in-php/"
---

Signal handling in PHP? Are we searching for alien signals coming from space?
No its all about handling system signals while executing cli scripts / apps.
What happens to my script when I press <ctrl+c>. Can I run a cleanup even if
the user actually wants to abort. What are signals anyway? And are signals only
there to kill/stop my script?
