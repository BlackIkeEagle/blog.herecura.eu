---
title: "SOHO DHCP DNS with dhcpd and bind"
description: "Setup your own dhcp/dns with automatic hostnames via dhcp"
date: "2014-03-23"
categories:
    - "linux"
    - "soho"
tags:
    - "dhcp"
    - "dns"
    - "Linux"
    - "Arch Linux"
---

Lets explain in clear and short how to setup a dhcp/dns with dhcpd and bind.

The goal is to have a predefined dns where the dhcp connected hosts are
automatically added so you get a more convenient way to connect to other
machines on your network. Especially not having to remember the ip address of
the others.

<!--more-->

> NOTE: the installation instructions given and the paths used will be fit for
  [Archlinux](https://www.archlinux.org), so interpollate for your distribution
  if needed.

## Install the packages

~~~sh
# pacman -Syu bind dhcp
~~~

## Setting up dns

Let us start from the default configuration. Initially we have to modify the
file /etc/named.conf, here we find the settings used to run our dns server.

> NOTE: the configuration files for bind must use tabs for indentation, so if
  you copy things from here, make sure indentation is with tabs, not spaces.

default `/etc/named.conf` in [Archlinux](https://www.archlinux.org):
~~~javascript
// 
// /etc/named.conf
//

options {
    directory "/var/named";
    pid-file "/run/named/named.pid";
    auth-nxdomain yes;
    datasize default;
// Uncomment these to enable IPv6 connections support
// IPv4 will still work:
//  listen-on-v6 { any; };
// Add this for no IPv4:
//  listen-on { none; };

    // Default security settings.
    allow-recursion { 127.0.0.1; };
    allow-transfer { none; };
    allow-update { none; };
    version none;
    hostname none;
    server-id none;
};

zone "localhost" IN {
    type master;
    file "localhost.zone";
    allow-transfer { any; };
};

zone "0.0.127.in-addr.arpa" IN {
    type master;
    file "127.0.0.zone";
    allow-transfer { any; };
};

zone "." IN {
    type hint;
    file "root.hint";
};

logging {
    channel xfer-log {
        file "/var/log/named.log";
        print-category yes;
        print-severity yes;
        print-time yes;
        severity info;
    };
    category xfer-in { xfer-log; };
    category xfer-out { xfer-log; };
    category notify { xfer-log; };
};
~~~

By default the forwarding of your DNS server is to one of the toplevel DNS
servers. Since this is our soho DNS we don't need to use a toplevel DNS server,
we can just use the DNS server of our ISP or you could use [Google Public
DNS](https://developers.google.com/speed/public-dns/) or
[OpenDNS](http://www.opendns.com/) for example.

To set these we need to add **forwarders** to our **options** in
`/etc/named.conf` and just add as much dns servers as we want, separated by
`;`.

In our example we will use [OpenDNS](http://www.opendns.com/) with fallback to
[Google Public DNS](https://developers.google.com/speed/public-dns/)

~~~javascript
options {
    directory "/var/named";
    pid-file "/run/named/named.pid";
    auth-nxdomain yes;
    datasize default;
// Uncomment these to enable IPv6 connections support
// IPv4 will still work:
//  listen-on-v6 { any; };
// Add this for no IPv4:
//  listen-on { none; };

    forwarders { 208.67.222.222; 8.8.8.8; };

    // Default security settings.
    allow-recursion { 127.0.0.1; };
    allow-transfer { none; };
    allow-update { none; };
    version none;
    hostname none;
    server-id none;
};
~~~

Now our dns server will get everything from the forwarders we configured,
**if** it cannot find the requested dns name in its own records.

Since we want to setup a SOHO DNS server we need to add our own zone. Lets name
it _myzone_.

First of all we need to add our zone and the reverse to `/etc/named.conf`.
Later we can configure our zone in a separate zone file.  We must already
decide what the ip range will be so we can define the reverse correctly, lets
use 192.168.1.0/24 in our setup.

Add the zone `/etc/named.conf`:

~~~javascript
zone "myzone.com" IN {
    type master;
    file "myzone.com.zone";
    allow-update { none; };
};
~~~

And the reverse:

~~~javascript
zone "1.168.192.in-addr.arpa" IN {
    type master;
    file "1.168.192.in-addr.arpa";
    allow-update { none; };
};
~~~

Why define the reverse ? Because when the reverse is defined you can use tools
to find out the dns name from the ip address.

So we have to define 2 extra configuration files `myzone.com.zone` and
`1.168.192.in-addr.arpa`. We find these files in `/var/named/`.

In our `myzone.com.zone` file we have to configure the information about our
zone. The first part of our zone file is the _origin_ and the _ttl_. Then the
first part of the configuration is the _SOA_ (Start of Authority), it contains
the global zone paramters. The _SOA_ must be the first _RR_ (Resource Record).
Further on we can define _A_ records and _CNAME_ records. We'll not define a
_MX_ record because mail is hosted outside the network.

The _SOA_ contains following items:

* serial number (most choose something like YYYYMMDDHH)
* refresh
* retry
* expiry
* nxdomain ttl

Example: `vim /var/named/myzone.com.zone`

~~~javascript
$ORIGIN myzone.com.
$TTL 604800 ; 1 week
@                   IN  SOA ns.myzone.com. root.myzone.com. (
                        2014032220 ; serial
                        604800     ; refresh (1 week)
                        86400      ; retry (1 day)
                        2419200    ; expire (4 weeks)
                        604800     ; minimum (1 week)
                        )
                    IN  NS  ns.myzone.com.

ns                  IN  A       192.168.1.1
www                 IN  A       192.168.1.2
blog                IN  CNAME   www
~~~

> NOTE: It is best to put the ns _A_ record on top so you get a good overview.

Now we have to define the reverse zone, which maps the specific ip address back
to a dns name.

Example: `vim /var/named/1.168.192.in-addr.arpa`

~~~javascript
$TTL 604800 ; 1 week
@                   IN  SOA ns.myzone.com. root.myzone.com. (
                        2014032220 ; serial
                        604800     ; refresh (1 week)
                        86400      ; retry (1 day)
                        2419200    ; expire (4 weeks)
                        604800     ; minimum (1 week)
                        )
                    IN  NS  ns.myzone.com.

1                   IN  PTR ns.myzone.com.
2                   IN  PTR www.myzone.com.
~~~

Now we have prepared our config file and our zone files. Before (re)starting
`named` we must check our configuration files.

~~~sh
# named-checkconf /etc/named.conf
~~~

When the above command returns 0 (true) this config is ok

Check our zone files
~~~sh
# named-checkzone myzone.com /var/named/myzone.com.zone
# named-checkzone 1.168.192.in-addr.arpa /var/named/1.168.192.in-addr.arpa
~~~

When all is ok , start the DNS server.

~~~sh
# systemctl start named.service
~~~

or restart

~~~sh
# systemctl restart named.service
~~~

Then we check if everything is ok with our named service
~~~sh
# systemctl status named.service
~~~

And we get something like:

~~~
named.service - Internet domain name server
   Loaded: loaded (/usr/lib/systemd/system/named.service; enabled)
   Active: active (running) since Sun 2014-03-23 08:19:46 CET; 14min ago
  Process: 32700 ExecStop=/usr/bin/rndc stop (code=exited, status=1/FAILURE)
 Main PID: 32702 (named)
   CGroup: /system.slice/named.service
           └─32702 /usr/bin/named -f -u named

Mar 23 08:19:46 MyZoneNs named[32702]: automatic empty zone: B.E.F.IP6.ARPA
Mar 23 08:19:46 MyZoneNs named[32702]: automatic empty zone: 8.B.D.0.1.0.0.2.IP6.ARPA
Mar 23 08:19:46 MyZoneNs named[32702]: command channel listening on 127.0.0.1#953
Mar 23 08:19:46 MyZoneNs named[32702]: managed-keys-zone: loaded serial 0
Mar 23 08:19:46 MyZoneNs named[32702]: zone myzone.com/IN: loaded serial 2014032220
Mar 23 08:19:46 MyZoneNs named[32702]: zone 0.0.127.in-addr.arpa/IN: loaded serial 42
Mar 23 08:19:46 MyZoneNs named[32702]: zone localhost/IN: loaded serial 42
Mar 23 08:19:46 MyZoneNs named[32702]: zone 1.168.192.in-addr.arpa/IN: loaded serial 2014032220
Mar 23 08:19:46 MyZoneNs named[32702]: all zones loaded
Mar 23 08:19:46 MyZoneNs named[32702]: running
~~~

## Setting up dhcp

Configuration of a dhcp server is fairly simple and straight forward. You can
check the default configuration file `/etc/dhcpd.conf` for extra information.
We will start from a blank slate because the default configuration has to much
information in it.

What we need for our dhcp server:

* server-identifier: put the ip address of the server here
* default-lease-time: how long a 'client' can keep its ip
* max-lease-time: this is when we force a 'client' to renew its lease
* authoritative: you state the configuration is correct and the server can act
as a dhcp server
* subnet
    * range
    * options
* host

Example: `vim /etc/dhcpd.conf`

~~~sh
#
# dhcpd.conf
#
server-identifier 192.168.1.1;
default-lease-time 28800;
max-lease-time 57600;
authoritative;

subnet 192.168.1.0 netmask 255.255.255.0
{
    range 192.168.1.20 192.168.1.250;
    option domain-name-servers 192.168.1.1;
    option domain-name "myzone.com";
    option routers 192.168.1.1;
    option broadcast-address 192.168.1.255;
}

host www {
    hardware ethernet 11:22:33:44:55:66;
    fixed-address 192.168.1.2;
}
~~~

So as you can see setting up a dhcp server is very easy.

Now we have prepared our config file. Before (re)starting `dhcpd` we must check
our configuration file.

~~~sh
# dhcpd -t -cf /etc/dhcpd.conf
~~~

When the above command returns 0 (true) this config is ok

When all is ok , start the dhcp server.

~~~sh
# systemctl start dhcpd4.service
~~~

or restart

~~~sh
# systemctl restart dhcpd4.service
~~~

Then we check if everything is ok with our named service
~~~sh
# systemctl status dhcpd4.service
~~~

And we get something like:
~~~
dhcpd4.service - IPv4 DHCP server
   Loaded: loaded (/etc/systemd/system/dhcpd4.service; enabled)
   Active: active (running) since Sat 2014-03-22 20:42:01 CET; 18h ago
  Process: 23571 ExecStart=/usr/sbin/dhcpd -4 -q -pf /run/dhcpd4.pid (code=exited, status=0/SUCCESS)
 Main PID: 23572 (dhcpd)
   CGroup: /system.slice/dhcpd4.service
           └─23572 /usr/sbin/dhcpd -4 -q -pf /run/dhcpd4.pid

Mar 23 14:00:22 MyZoneNs dhcpd[23572]: Wrote 0 new dynamic host decls to leases file.
Mar 23 14:00:22 MyZoneNs dhcpd[23572]: Wrote 15 leases to leases file.
Mar 23 14:00:22 MyZoneNs dhcpd[23572]: DHCPREQUEST for 192.168.1.89 from 22:33:44:55:66:77 (Client1) via eth1
Mar 23 14:00:22 MyZoneNs dhcpd[23572]: DHCPACK on 192.168.1.89 to 22:33:44:55:66:77 (Client1) via eth1
Mar 23 14:04:17 MyZoneNs dhcpd[23572]: DHCPREQUEST for 192.168.1.91 from bb:aa:00:99:88:77 (Client2) via eth1
Mar 23 14:04:17 MyZoneNs dhcpd[23572]: DHCPACK on 192.168.1.91 to bb:aa:00:99:88:77 (Client2) via eth1
Mar 23 14:25:42 MyZoneNs dhcpd[23572]: DHCPREQUEST for 192.168.1.89 from 22:33:44:55:66:77 (Client1) via eth1
Mar 23 14:25:42 MyZoneNs dhcpd[23572]: DHCPACK on 192.168.1.89 to 22:33:44:55:66:77 (Client1) via eth1
Mar 23 14:54:04 MyZoneNs dhcpd[23572]: DHCPREQUEST for 192.168.1.89 from 22:33:44:55:66:77 (Client1) via eth1
Mar 23 14:54:04 MyZoneNs dhcpd[23572]: DHCPACK on 192.168.1.89 to 22:33:44:55:66:77 (Client1) via eth1
~~~

## Bringing them together

The only thing left to do is to make sure that all dhcp connected machines are
nicely added to the zone so we can connect to them by using their hostname and
not having to remember all the ip addresses.

First we will update our DNS configuration so later on the dhcpd can update dns
records. Therefore we have to add a _key_ to use and configure _controls_ which
will define how and where the dns can be updated. We will also have to update
our zone configuration to allow update.

First we will add the _key_ to our `/etc/named.conf` file. The _key_ has a name
and then as two parts, the algoritm and the secret

~~~javascript
key myzone {
    algorithm hmac-md5;
    secret b3ef79c3e56750ad01de5c2cf0d11547;
};
~~~

And then we add the controls to `/etc/named.conf`. The controls state where to
listen and what hosts to allow and the key that is valid.

~~~javascript
controls {
    inet 127.0.0.1 port 953 
    allow { 127.0.0.1; 192.168.1.1; } keys { "myzone"; };
};
~~~

We also have to update our own zone entries in `/etc/named.conf` to allow them
to be updated.

~~~javascript
zone "myzone.com" IN {
    type master;
    file "myzone.com.zone";
    allow-update { key myzone; };
};

zone "1.168.192.in-addr.arpa" IN {
    type master;
    file "1.168.192.in-addr.arpa";
    allow-update { key myzone; };
};
~~~

Now our dns configuration should be ok to allow dhcpd to add and remove entries
from our zone.

We have to update our `/etc/dhcpd.conf` file so our dhcp server will send the
information to the dns server.  Therefore we have to add **ddns-update-style
interim;** and we also have to add the _key_ and the _zone_ configurations.

~~~sh
#
# dhcpd.conf
#
server-identifier 192.168.1.1;
default-lease-time 28800;
max-lease-time 57600;
authoritative;

ddns-update-style interim;

key myzone {
    algorithm hmac-md5;
    secret b3ef79c3e56750ad01de5c2cf0d11547;
};

zone myzone.com. {
    primary 192.168.1.1;
    key myzone;
}

zone 1.168.192.in-addr.arpa. {
    primary 192.168.1.1;
    key myzone;
}

subnet 192.168.1.0 netmask 255.255.255.0
{
    range 192.168.1.20 192.168.1.250;
    option domain-name-servers 192.168.1.1;
    option domain-name "myzone.com";
    option routers 192.168.1.1;
    option broadcast-address 192.168.1.255;
}

host www {
    hardware ethernet 11:22:33:44:55:66;
    fixed-address 192.168.1.2;
}
~~~

Now our machines connected via dhcp can be added to our dns zone and so it will
be a lot easier to reach them.

This kind of setup has one quirck, we need to make sure the startup order of
bind and dhcpd is correct. First `named` must be started and then `dhcpd`.

To make sure `dhcpd4` is started after `named` we override the `dhcpd4.service`
file with our modified version.

~~~sh
# cp /usr/lib/systemd/system/dhcpd4.service /etc/systemd/system/dhcpd4.service
~~~

Make sure that `dhcpd4` is started after `named`:

~~~
[Unit]
Description=IPv4 DHCP server
After=named.service

[Service]
Type=forking
PIDFile=/run/dhcpd4.pid
ExecStart=/usr/sbin/dhcpd -4 -q -pf /run/dhcpd4.pid
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
~~~

## Closing note

This style of configuration I'm dragging along since 2006, at the time I was
using a [Slackware](http://www.slackware.com) machine as my SOHO server. Maybe
there are some things that are not done excactly right. But I know one thing
for sure, it serves me well up till now so there must be something right :).

I hope the article is informative and sufficient to setup this kind of setup in
  your home network.
