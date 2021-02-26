---
title: "Proxying MySQL, setting things up"
description: "An attempt to improve remote mysql performance"
date: "2021-02-18"
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

If we want to host our MySQL dabase on other machines, is there a way to easily
passthrough our mysql traffic, and how much performance impact can we expect?

We'll have to figure that out. But therefore we first have to start by
understanding what the proxies can do and how to set those up.

We will try some proxies with sysbench and see what that gives us.

<!--more-->

## Local playground

We will setup a local proxy playground to try stuff on our local machine.
Mostly to get to know the configuration of the different setups and to toy
around.

We will create the playground with `docker-compose` and use the following
services:

- [MySQL][1] (Percona Server) 8.0.22-13
- [Haproxy][2] 2.3.5
- [Traefik][3] 2.4.3
- [ProxySQL][4] 2.0.17

We are not going in too much detail about the configuration, both Haproxy and
Traefik are TCP proxies, where ProxySQL actually understands SQL. In ProxySQL
we also try to enable some caching.

The [docker-compose setup][5]

## Sysbench

### Prepare the database

```sh
#!/usr/bin/env bash

sysbench \
    /usr/share/sysbench/oltp_read_only.lua \
    --threads=$(nproc) \
    --tables=10 \
    --table-size=1000000 \
    --mysql-host=mysql.sysbench.test \
    --mysql-port=3306 \
    --mysql-user=bench \
    --mysql-password=bench \
    --mysql-db=bench \
    --mysql-storage-engine=INNODB \
    prepare
```

We create 10 tables with 1000000 entries in our `bench` db and we will make
sure its using `InnodDB` storage.

We'll focus on read only performance since that will be the main factor of our
application to slow down.

### Benchmark

The benchmark on the local machine will not be used as baseline, but mostly as
playground to set some expectations. For the actual test we will use production
hardware. To get a somewhat correct expectation we will not go full force
benchmark here, but try to get a ballpark idea how much difference there is
between direct use of MySQL and the proxies.

```sh
#!/usr/bin/env bash

sysbench \
    /usr/share/sysbench/oltp_read_only.lua \
    --threads="$(($(nproc)/4))" \
    --tables=10 \
    --table-size=1000000 \
    --report-interval=5 \
    --rand-type=pareto \
    --forced-shutdown=1 \
    --time=300 \
    --events=0 \
    --point-selects=25 \
    --range_size=5 \
    --skip_trx=on \
    --percentile=95  \
    --mysql-host=mysql.sysbench.test \
    --mysql-port=3306 \
    --mysql-user=bench \
    --mysql-password=bench \
    --mysql-db=bench \
    --mysql-storage-engine=INNODB \
    run
```

By only using 1/4th of our available threads of our local machine, there is
pleny of headroom for the proxy and MySQL.

## MySQL

```
SQL statistics:
    queries performed:
        read:                            10277484
        write:                           0
        other:                           0
        total:                           10277484
    transactions:                        354396 (1181.30 per sec.)
    queries:                             10277484 (34257.65 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          300.0039s
    total number of events:              354396

Latency (ms):
         min:                                    1.62
         avg:                                    2.54
         max:                                   14.96
         95th percentile:                        3.30
         sum:                               899590.39

Threads fairness:
    events (avg/stddev):           118132.0000/150.43
    execution time (avg/stddev):   299.8635/0.00
```

We will take 2 values from here as a basic comparison, transactions/sec and queries/sec.

transactions/sec | queries/sec
----------------:|-----------:
 1181.30         | 34257.65

## Haproxy

```
SQL statistics:
    queries performed:
        read:                            5588445
        write:                           0
        other:                           0
        total:                           5588445
    transactions:                        192705 (642.33 per sec.)
    queries:                             5588445 (18627.70 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          300.0059s
    total number of events:              192705

Latency (ms):
         min:                                    2.57
         avg:                                    4.67
         max:                                   28.96
         95th percentile:                        6.21
         sum:                               899709.93

Threads fairness:
    events (avg/stddev):           64235.0000/52.20
    execution time (avg/stddev):   299.9033/0.00
```

type     | transactions/sec | queries/sec
---------|-----------------:|-----------:
MySQL    | 1181.30          | 34257.65
Haproxy  | 642.33           | 18627.70

## Traefik

```
SQL statistics:
    queries performed:
        read:                            5729124
        write:                           0
        other:                           0
        total:                           5729124
    transactions:                        197556 (658.50 per sec.)
    queries:                             5729124 (19096.63 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          300.0056s
    total number of events:              197556

Latency (ms):
         min:                                    2.53
         avg:                                    4.55
         max:                                   30.08
         95th percentile:                        5.88
         sum:                               899711.49

Threads fairness:
    events (avg/stddev):           65852.0000/37.16
    execution time (avg/stddev):   299.9038/0.00
```

type     | transactions/sec | queries/sec
---------|-----------------:|-----------:
MySQL    | 1181.30          | 34257.65
Traefik  | 658.50           | 19096.63

## ProxySQL

```
SQL statistics:
    queries performed:
        read:                            3576048
        write:                           0
        other:                           0
        total:                           3576048
    transactions:                        123312 (411.03 per sec.)
    queries:                             3576048 (11919.85 per sec.)
    ignored errors:                      0      (0.00 per sec.)
    reconnects:                          0      (0.00 per sec.)

General statistics:
    total time:                          300.0063s
    total number of events:              123312

Latency (ms):
         min:                                    4.07
         avg:                                    7.30
         max:                                   35.16
         95th percentile:                        9.56
         sum:                               899794.15

Threads fairness:
    events (avg/stddev):           41104.0000/16.97
    execution time (avg/stddev):   299.9314/0.00
```

type     | transactions/sec | queries/sec
---------|-----------------:|-----------:
MySQL    | 1181.30          | 34257.65
ProxySQL | 411.03           | 11919.85

## Basic conclusion

type     | transactions/sec | queries/sec | percentage
---------|-----------------:|------------:|----------:
MySQL    | 1181.30          | 34257.65    | 100%
Haproxy  | 642.33           | 18627.70    | 54.38%
Traefik  | 658.50           | 19096.63    | 55.74%
ProxySQL | 411.03           | 11919.85    | 34.79%

So direct queries on MySQL are by default the best solution. Note that this
test is just a benchmark and does not say anything about real life traffic.
ProxySQL is notable much slower compared to the others, a sidenote we have to
make here is that even though SELECT caching was enabled ProxySQL does not
apply it because all queries done in sysbench are prepared statements and those
can't be cached in ProxySQL. Both Haproxy and Traefik get a bit over 50% of the
throughput compared to direct MySQL.

The next test will be done on actual production hardware with real networking,
not just virtual networking via docker. Read in [Part2][6].

And as a final test we should compare an application an how much we see
performance impact. Read in Part 3 (TODO).

[1]: https://www.percona.com/software/mysql-database/percona-server
[2]: https://www.haproxy.org
[3]: https://traefik.io/traefik/
[4]: https://proxysql.com
[5]: https://github.com/BlackIkeEagle/proxysql-playground
[6]: https://blog.herecura.eu/blog/2021-02-26-proxying-mysql-benchmarking-on-production-hardware/
