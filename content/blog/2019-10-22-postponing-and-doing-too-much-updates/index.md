---
title: "Postponing maintenance and then doing too much at once"
description: "Mistakes were made"
date: "2019-10-22"
categories:
  - "Arch Linux"
  - "linux"
  - "vps"
  - "letsencrypt"
  - "CentOS"
tags:
  - "linux"
---

## The "Oh I forgot" moment

21 october, late in the afternoon, suddenly it pops in my mind - Damn some
letsencrypt certificates are about to expire and I ignored all notifications.
That was 17.00h and the certificates were expiring at 19.00h. First ofcourse
have diner, do  something with the kids, get them to bed, ...

So yeah 20.00h when I started looking at it. Somewhere due lack of updates or a
confiugration bug, the script that was meant to update my letsencrypt
certificates failed. And I blatantly ignored multiple notifications the
certificates were about to expire. So all entirely my fault.

<!--more-->

## A trigger moment

Well, since those certificates are expired, why not move all this stuff from
this old CentOS machine to a new one. Yeah, why not, stuff is broken anyway and
I already prepared my ansible for the move already. So thought, so done. Create
new vps, now with Arch Linux and start installing stuff with ansible. The
CentOS machine already showed up on my bill for over a year as
"herecura-to-be-replaced".

![herecura-to-be-replaced](Screenshot_20191022_081051.png)

## Oops

All went fairly well, some hickups with a database I wanted to transfer, but
all in all not too many problems. I started to stop services on the old machine
so I could migrate them nicely, and bring them back up on the new machine. And
then it happend - Hmm letsencrypt errors, how wierd.

```
acme: Error -> One or more domains had a problem:\n[whatever.example] acme: error: 400 :: urn:ietf:params:acme:error:connection
```

Forgot about DNS ofcourse :(. All my DNS records are on 24 hour TTL and I
completely forgot in my enthousiasm to finally move to this new machine.

## Conclusion

So because I was to lazy to first fix the issue with letsencrypt and then later
- maybe another year, who knows - migrate to a new machine. I got too exited
and moved to a new machine without thinking about DNS. Foolish me. There are a
couple of valuable lessons I learned again. I should not postpone some
maintenance and should plan my stuff better **and** make time for it.
Definitely instead of pushing into the wee hours because I got too exited and
forgot to properly think things through.

So that is why I've had issues with letsencrypt for about 12 hours. And instead
I could probably fix the issue and have an expired certificate for 1 or 2
hours. But hey, I have my stuff running on a brand new machine now :)
