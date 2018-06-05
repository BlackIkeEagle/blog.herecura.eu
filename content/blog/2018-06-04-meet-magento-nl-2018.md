---
title: "Meet Magento NL 2018"
description: "Meet Magento NL 2018 experience"
date: "2018-06-04"
categories:
  - "development"
  - "conference"
tags:
  - "development"
  - "conference"
---

Surprise, I went to Meet Magento NL 2018. Actually this was a little surprise for me too. Originally I had submitted a few talks for this conference, but I did not know how it went. Since we already discussed at work to go to DPC 2018 I thought, maybe next year. Around 2 weeks before the event I got an email from Sander telling me something went wrong with the feedback on my proposals and they were offering me a ticket to attend the conference. I was happy with the proposal but still doubted shortly if I would go or not since that would be 2 weeks in a row going away, and I still have work to to in our house. But I really wanted to see some people speak and was interested to hear their experiences. So there I went, to Meet Magento NL 2018.

<!--more-->

## The trip

![On the road](/blog/2018-06-04-meet-magento-nl-2018/IMG_20180531_163936584.jpg) 

Going by train to Utrecht was interesting. I'm not using public transport that much since I'm usually going everywhere by bike. The fastest suggested route was "Brugge -> Antwerpen Centraal", "Antwerpen Centraal -> Rotterdam Centraal", "Rotterdam Centraal -> Utrecht". Overall a nice experience where the only added delay was due to Thalys being delayed already and then had a technical issue in Antwerpen Centraal. So I missed my connection to Utrecht in Rotterdam Centraal. Not too bad since there was another direct train to Utrecht within 30 minutes.

![Antwerp Centraal from below](/blog/2018-06-04-meet-magento-nl-2018/IMG_20180531_181412439.jpg)

## The conference

![Meet Magento NL Sign](/blog/2018-06-04-meet-magento-nl-2018/DenOzZWWkAE9bh4.jpg)

I arrived early on the conference day, a little over 9 o'clock I got my lanyard with conference badge. I was ready to explore the conference space, see to get me some water, check where the rooms were, so I made myself familiar with the space.

![The hall](/blog/2018-06-04-meet-magento-nl-2018/DemFTEUXUAACrgS.jpg)

I already had a list of talks I really wanted to see:

- "Manipulating Magento" by Joke Puts
- "Magento from dev to prod with Gitlab CI" by Stephan Hochdörfer
- "Dependency Injection Extended" by Andreas von Studnitz
- "Magento 2 under siege" by Riccardo Tempesta
- "Power to the front-end developers" by Jamie Maria Schouren

Ofcourse there had to be some room to talk to people along the way.

### Opening and opening keynote

![Opening](/blog/2018-06-04-meet-magento-nl-2018/IMG_20180601_094441733.jpg)

The opening was hosted by Rebecca Brocton & TJ Gamble. It was preceeded with a funny introduction of both, how they were asked to host Meet Magento NL. It was a nice and funny opening, with a great overview what would be done throughout the day.

![opening keynote growth hacking](/blog/2018-06-04-meet-magento-nl-2018/IMG_20180601_095224299_LL.jpg)

Chris Out was presenting us with an interesting keynote about growth hacking. What I understood was that it's all about bringing all involved people together, sales, developers, marketing, … and make them work together to achieve the growth goal. The goal is to find the 'thing' that makes your customers happy and makes them come back. Very important takeaway: "Reduce friction, improve customer satisfaction" and get as result "Improved conversion".

### Manipulating Magento

![Manipulating Magento](/blog/2018-06-04-meet-magento-nl-2018/IMG_20180601_103011804.jpg)

I have seen a previous version of this talk by Joke Puts before so I had already an idea what to expect. I was certainly not dissapointed and there was new information in the talk. The delivery was great and easy to digest with very insightfull information to make your life easier to survive Magento updates. There were a ton of great tips, how to use plugins, observers and preferences. The main takeway could be "Only use preferences as a last resort, when there is no other option left".

### Magento from dev to prod with GitLab CI

![GitLab](/blog/2018-06-04-meet-magento-nl-2018/IMG_20180601_120133519.jpg)

My interest was very high seeing this talk, because I was really interested what GitLab could possibly do for us. I have seen Stephan Hochdörfer speak before so I already had some idea how he approaches things. Funny thing that he mentioned he had to reduce his presentation, he assumed, as I did the first time I went to a Meet Magento, that the talking slots would be 50 minutes. We got a great overview of what GitLab can do for all of us, and especially that you are free to use whatever part you like of it. All super nice features GitLab brings to the table were clearly explained and visualized how it would behave. There were not really specific Magento parts in the talk so I guess some people might have wanted more, but overall there were only 25 minutes :).

### Dependency Injection Extended: the way to advanced Magento 2 development

![DI](/blog/2018-06-04-meet-magento-nl-2018/IMG_20180601_123230586.jpg)

Andreas von Studnitz brought us a fairly in depth talk about Magento Dependency Injection and how you can leverage it. First we got a step by step insight in how the Dependency Injection works in Magento and how it behaves when you are adding preferences to the table. There was also a very nice part about Virtual Types, where you could clearly see this is a very powerfull feature, but you should use it with care. It was really nice to get this explained fairly in depth because once you understand these behaviours it makes it a lot easier to understand how to use DI in Magento and what it can do.

### Magento 2 under siege: defense strategies and attack patterns identification

![under siege](/blog/2018-06-04-meet-magento-nl-2018/IMG_20180601_140300090.jpg)

Since this talk was about security I also really wanted to see this. Riccardo Tempesta showed us that a slight mistake in a custom built extension, or a bought extension can have desaterous concequences. One simple injection possibility could lead to a remote shell being installed, your whole database being downloaded and as a result your users passwords cracked withing minutes. With tools like sqlmap and hashcat you can quickly achieve such result. On the other hand there are still the XSS possibilities where the example only added clippy to a magento store and a fake download link for Magento 3, but it could be worse than that. I very much enjoyed this talk, mostly as a reminder that we must proactivly check our websites for these kind of issues and there are a lot of tools out there that can get us results quickly.

### Power to the front-end developers: GraphQL & PWA

![PWA GraphQL](/blog/2018-06-04-meet-magento-nl-2018/IMG_20180601_143451540.jpg)

Since I'm personally more a backend developer, even leaning more towards operations I was very interested to know about this shift and what it could mean for our platforms and how we build them. Jamie Maria Schouren brought us a very well delivered talk, that really showed what PWA and GraphQL can bring us in the near future. Mostly because the presentation layer is decoupled from the 'backend' you get to a place where you can do whatever you want and get your data wherever you want. That power brought to you by PWA and GraphQL is massive. The old paradigm where the backend developers already build the structure and the frontend developer styles and adds some bells and whisles is gone, bye bye to it and it will never come back.

### Hallwaytrack

There were ofcourse interesting discussions in the hallwaytrack. And its always nice to see people you know but haven't seen in a while. It's also great to meet some new people and have some nice talks about all sorts of technology or related fields.

## Closing

I had a great time, saw interesting talks and people, got some inspiration and ideas to work on. I had to leave early so there might have been more time to talk to people but it is what it is. For the technical track I personally think it might be usefull to offer slots of 25 minutes (current) and slots of 50 minutes. Some things need sufficient background to get explained properly and 25 minutes might not cut it. Overall great time and hope to see you all again another time.

![mm18nl](/blog/2018-06-04-meet-magento-nl-2018/IMG_20180601_091000539.jpg)
