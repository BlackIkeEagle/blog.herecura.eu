---
title: "Proxying MySQL, conclusion"
description: "An attempt to improve remote mysql performance"
date: "2021-03-02"
categories:
  - "mysql"
  - "containers"
tags:
  - "mysql"
  - "haproxy"
  - "traefik"
  - "proxysql"
  - "linux"
  - "server"
---

After running some tests with different proxies:

- [Proxying MySQL, setting things up][1]
- [Proxying MySQL, benchmarking on production hardware][2]
- [Proxying MySQL, Wordpress and Magneto performance][3]

What can we decide and how do we will deploy and use MySQL.

<!--more-->

## Overall conclusion

When you have applications that have a lot of "cold" hits on MySQL we have seen
that having the MySQL server on the local machine gives us the most throughput.
When we are using some Proxy, the regular TCP proxies end up being a little
slower compared to a remote MySQL connection. And in that case ProxySQL does
not offer us any benefit, but rather an additional loss in throughput.

Using the default sysbench read only tests we found out that ProxySQL does not
cache prepared statements, hence we can confirm in that case ProxySQL does not
offer us anything.

Once we started testing with 2 applications we found that mostly ProxySQL gives
us a very nice benefit because it can cache the results locally and hence
reduce the roundtrip drastically compared to regular TCP proxies. The main
drawback we think of in this case is that you need enough traffic and related
to that probably a big enough database to justify this setup.

If we look at this from the standpoint of shared hosting, we must conclude, to
have the best performance for all types of customers we have there is only one
option for us; host the MySQL database on the same machine where the code is
running. This is the only case where cold hits - uncached results - or warm
hits will perform good enough.

We did this research to see if we could leverage a proxy to transparently serve
MySQL 5.7 and MySQL 8.0 database to end user applications, but the huge impact
on throughput does not allow us to do so.

[1]: https://blog.herecura.eu/blog/2021-02-18-proxying-mysql-setting-things-up/
[2]: https://blog.herecura.eu/blog/2021-02-26-proxying-mysql-benchmarking-on-production-hardware/
[3]: https://blog.herecura.eu/blog/2021-03-02-proxying-mysql-wordpress-and-magento/
