---
title: "Handling signals in PHP"
description: "How do we properly handle signals sent to your php script/app"
date: "2016-12-07"
categories:
    - "signals"
    - "posix"
    - "php"
tags:
    - "Posix"
    - "PHP"
meetuplogo: "/images/logo_phpleuven.jpeg"
slides: "/talks/20161207-handling-signals-in-php/"
---

Signal handling in PHP? Are we searching for alien signals coming from space?
No its all about handling system signals while executing cli scripts / apps.
What happens to my script when I press <ctrl+c>. Can I run a cleanup even if
the user actually wants to abort. What are signals anyway? And are signals only
there to kill/stop my script?
