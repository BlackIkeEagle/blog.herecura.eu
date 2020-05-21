---
title: "Toying around with firecracker"
description: ""
date: "2020-05-21"
categories:
  - "Arch Linux"
  - "linux"
  - "microvm"
  - "kvm"
tags:
  - "linux"
---

[Firecracker][1] "Secure and fast microVMs for serverless computing". That
triggers a lot, secure, fast and serverless, so something with containers? So
Lets play around with firecracker and see what it can do.

<!--more-->

## What?

> Firecracker is an open source virtualization technology that is purpose-built
> for creating and managing secure, multi-tenant container and function-based
> services.

So firecracker basically is a kvm virtual machine that boots massively fast to
pretend it is a container. But since it is full virtualization it is more
secure than what container primitives in Linux can give us.

## Our goal

We want single service containers. This in a multi-tenant environment where the
tenants must be isolated from each other. We want something that gets a new
service up and running as fast as possible. Containers are the answer here, but
we really want the maximum isolation possible. Firecracker is a good candidate
here since it promises that, we don't necessarily have the highly dynamic
environment like serverless but it could fit our purpose.

## Ecosystem

One important thing to know is, is there enough ecosystem around this project
to make it work for our use case. And is our use case something for
firecracker.

Firecracker itself is written in [rust][2]. Since this is a language on the
rise the general knowledge of this language might be a barrier. Also
firecracker does some really low level stuff with kvm and is very specifically
built for the goal they had in mind.

We find some tools that use or wrap firecracker:

- [firectl][3]: a convenience wrapper to spin up firecracker vms
- [firecracker-containerd][4]: manage containers as firecracker microvms
- [Weaveworks Ignite][5]: uses firecracker to run OCI images
- [Kata Containers][6]: can use firecracker underneath next to qemu

So there are some tools available, and most are there to integrate with
existing container tooling like [kubernetes][7], [containerd][8], or to use
container images as vms.

So the tooling is very container centric, maybe those do not exactly fit our
initial goal, but firecracker by itself is promising.

## Initial setup

Lets go, can we get it running and does it even work. We can find a nice
[Getting Started with Firecracker][9] in the github repo.

We can add ourselves to the `kvm` group to get read-write access to `/dev/kvm`.
Maybe our user is already in the `kvm` group due to playing around with kvm
before. Or we could follow the `setfacl` method we can find in the getting
started document.

We can find the `firecracker` binary on the [releases][10] page. Use the
latest version. At the time of testing our firecracker has version 0.21.1.

Make sure to make `firecracker` available in the `PATH`, for example put it
in `/usr/local/bin/firecracker` and make sure it is executable.

## Hello World

The first vm :).

We must get the hello kernel and hello rootfs for our hello world example. This
is nicely described in the "Getting started with Firecracker" document.

```sh
mkdir hello
cd hello
curl -fsSL -o hello-vmlinux.bin https://s3.amazonaws.com/spec.ccfc.min/img/hello/kernel/hello-vmlinux.bin
curl -fsSL -o hello-rootfs.ext4 https://s3.amazonaws.com/spec.ccfc.min/img//hello/fsfiles/hello-rootfs.ext4
```

So now we have that, how to use this. We fist start `firecracker` so we can use
its api to configure and start a vm.

We use a helper script to start firecracker because it does not clean its
socket after exit so we do that in our little
[start-firecracker.sh](./start-firecracker.sh) helper.

```sh
#!/usr/bin/env bash

firecracker --api-sock "$(pwd)"/firecracker.socket
rm firecracker.socket
```

```sh
$ ./start-firecracker.sh
```

Ok firecracker is running, nothing there yet. We must add the uncompressed
Linux kernel and a rootfs to make it boot.

Set the kernel [set-kernel.sh](./set-kernel.sh):

```sh
#!/usr/bin/env bash

kernel_path="$(pwd)/hello-vmlinux.bin"

curl --unix-socket "$(pwd)"/firecracker.socket -i \
    -X PUT 'http://localhost/boot-source'   \
    -H 'Accept: application/json'           \
    -H 'Content-Type: application/json'     \
    -d "{
        \"kernel_image_path\": \"${kernel_path}\",
        \"boot_args\": \"console=ttyS0 reboot=k panic=1 pci=off\"
    }"
```

Set the rootfs [set-rootfs.sh](./set-set-rootfs.sh)

```sh
#!/usr/bin/env bash

rootfs_path="$(pwd)/hello-rootfs.ext4"

curl --unix-socket "$(pwd)"/firecracker.socket -i \
    -X PUT 'http://localhost/drives/rootfs' \
    -H 'Accept: application/json'           \
    -H 'Content-Type: application/json'     \
    -d "{
        \"drive_id\": \"rootfs\",
        \"path_on_host\": \"${rootfs_path}\",
        \"is_root_device\": true,
        \"is_read_only\": false
    }"
```

So we can now set the kernel and rootfs.

```sh
$ ./set-kernel.sh
$ ./set-rootfs.sh
```

Both times we get a successful response:

```
HTTP/1.1 204 
Server: Firecracker API
Connection: keep-alive
```

Now that we have everything, all we have to to is launch this instance and see
what what happens. We will launch with [start-vm.sh](./start-vm.sh).

```sh
#!/usr/bin/env bash

curl --unix-socket "$(pwd)"/firecracker.socket -i \
    -X PUT 'http://localhost/actions'       \
    -H  'Accept: application/json'          \
    -H  'Content-Type: application/json'    \
    -d '{
        "action_type": "InstanceStart"
    }'
```

Execute

```sh
$ ./start-vm.sh
```

Again we get a 204 response as before, so the request was successful but there
is no content.

Now we see activity where we started firecracker itself.

```
...
 [ ok ]
 * Mounting persistent storage (pstore) filesystem ...
 [ ok ]
Starting default runlevel
[    1.056497] clocksource: tsc: mask: 0xffffffffffffffff max_cycles: 0x1fb62f12e8c, max_idle_ns: 440795238402 ns

Welcome to Alpine Linux 3.8
Kernel 4.14.55-84.37.amzn2.x86_64 on an x86_64 (ttyS0)

localhost login:
```

Yaay its alive. From the getting started we get that the login here is `root`
with password `root`. Lets see some system info.

```
localhost:~# uname -a
Linux localhost 4.14.55-84.37.amzn2.x86_64 #1 SMP Wed Jul 25 18:47:15 UTC 2018 x86_64 Linux
localhost:~# top
Mem: 10928K used, 104032K free, 80K shrd, 480K buff, 2804K cached
CPU:   0% usr   0% sys   0% nic 100% idle   0% io   0% irq   0% sirq
Load average: 0.00 0.00 0.00 1/35 859
  PID  PPID USER     STAT   VSZ %VSZ CPU %CPU COMMAND
  847     1 root     S     4972   4%   0   0% supervise-daemon agetty.ttyS0 --st
    1     0 root     S     2848   2%   0   0% {openrc-init} /sbin/init
  855   849 root     S     1612   1%   0   0% -ash
  859   855 root     R     1524   1%   0   0% top
  849   847 root     S     1516   1%   0   0% /bin/login -- root
  132     2 root     IW       0   0%   0   0% [kworker/0:1]
    7     2 root     SW       0   0%   0   0% [ksoftirqd/0]
    6     2 root     IW<      0   0%   0   0% [mm_percpu_wq]
    8     2 root     IW       0   0%   0   0% [rcu_sched]
   10     2 root     SW       0   0%   0   0% [migration/0]
   11     2 root     SW       0   0%   0   0% [cpuhp/0]
   12     2 root     SW       0   0%   0   0% [kdevtmpfs]
   13     2 root     IW<      0   0%   0   0% [netns]
   14     2 root     IW       0   0%   0   0% [kworker/u2:1]
    4     2 root     IW<      0   0%   0   0% [kworker/0:0H]
    2     0 root     SW       0   0%   0   0% [kthreadd]
  133     2 root     IW<      0   0%   0   0% [writeback]
  134     2 root     SW       0   0%   0   0% [kcompactd0]
  136     2 root     SWN      0   0%   0   0% [ksmd]
  137     2 root     IW<      0   0%   0   0% [crypto]
localhost:~# ip a
1: lo: <LOOPBACK> mtu 65536 qdisc noop state DOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
localhost:~# df -ah
Filesystem                Size      Used Available Use% Mounted on
/dev/root                28.0M     21.1M      4.9M  81% /
devtmpfs                 10.0M         0     10.0M   0% /dev
proc                         0         0         0   0% /proc
tmpfs                    11.2M     80.0K     11.1M   1% /run
mqueue                       0         0         0   0% /dev/mqueue
devpts                       0         0         0   0% /dev/pts
shm                      56.1M         0     56.1M   0% /dev/shm
binfmt_misc                  0         0         0   0% /proc/sys/fs/binfmt_misc
sysfs                        0         0         0   0% /sys
securityfs                   0         0         0   0% /sys/kernel/security
debugfs                      0         0         0   0% /sys/kernel/debug
selinuxfs                    0         0         0   0% /sys/fs/selinux
pstore                       0         0         0   0% /sys/fs/pstore
```

So the hello world is a bare minimum [Alpine Linux][11] 3.8 which is sortof old
already :p. The uncompressed kernel is extremely small and stripped down as far
as they possibly could to make it boot fast.

## The API

Firecracker exposes a http api over the socket. The [api][12] is defined via
swagger (now OpenAPI). Since this is a swagger api its easy to understand and
work with.

We can enable metrics, update disks, add or update network interfaces via the
api. Feel free to toy around with it.

## Start a vm from a configuration file

If we already know how the guest must be configured we can use a json file with
all the requirements already there. Then we don't have to issue multiple api
calls to configure the future instance. In [vm_config.json](./vm_config.json)
we predefine how the vm will look like, and with
[start-vm-from-config.sh](./start-vm-from-config.sh) we give firecracker the
additional cli flag `--config-file vm_config.json`.

```json
{
  "boot-source": {
    "kernel_image_path": "hello-vmlinux.bin",
    "boot_args": "console=ttyS0 reboot=k panic=1 pci=off"
  },
  "drives": [
    {
      "drive_id": "rootfs",
      "path_on_host": "hello-rootfs.ext4",
      "is_root_device": true,
      "is_read_only": false
    }
  ],
  "machine-config": {
    "vcpu_count": 2,
    "mem_size_mib": 1024,
    "ht_enabled": false
  }
}
```

```sh
#!/usr/bin/env bash

firecracker --api-sock "$(pwd)"/firecracker.socket --config-file vm_config.json
rm firecracker.socket
```

```sh
$ ./start-vm-from-config.sh
```

Now we immediately get a running vm without having to interact with the api.
With predefined services this can come in handy.

## Custom build

Here we want to explore if we can run another rootfs, can we easily build
another. And how easy is it to use a more up-to-date kernel.

The easiest way is to use [Arch Linux][13], since we are most familiar with
that.

Building an Arch Linux rootfs is relatively straight forward. We can do this on
a local machine where Arch Linux is installed. In case you have no Arch Linux
installation running you could use docker to accomplish the same. First we are
going to make a sparse file of 2GB, format it with ext4 and install `base`
which is the bare minimum. Since the init is going to be systemd, we will
remove everything in the `/etc/systemd/system/*.target/` folders and we will
also mask `systemd-random-seed.service` and `cryptsetup.target` since we are
not needing those. For the ease of recreating the rootfs we have a little
script [create-arch-rootfs.sh](./create-arch-rootfs.sh).

```sh
#!/usr/bin/env bash

[[ -e arch-rootfs.ext4 ]] && rm arch-rootfs.ext4

truncate -s 2G arch-rootfs.ext4
sudo mkfs.ext4 arch-rootfs.ext4

sudo mkdir -p /mnt/arch-root
sudo mount "$(pwd)"/arch-rootfs.ext4 /mnt/arch-root
sudo pacstrap /mnt/arch-root base

echo "firecracker-arch" | sudo tee -a /mnt/arch-root/etc/hostname
sudo rm /mnt/arch-root/etc/systemd/system/getty.target.wants/*
sudo rm /mnt/arch-root/etc/systemd/system/multi-user.target.wants/*
ln -s /dev/null /mnt/arch-root/etc/systemd/system/systemd-random-seed.service
ln -s /dev/null /mnt/arch-root/etc/systemd/system/cryptsetup.target
sudo arch-chroot /mnt/arch-root passwd -d root

sudo umount /mnt/arch-root
sudo rmdir /mnt/arch-root
```

So lets see if we can get this started and another helper to set the Arch
rootfs [set-arch-rootfs.sh](./set-arch-rootfs.sh)

```sh
$ ./start-firecracker.sh
```

And use the hello kernel with our minimal Arch Linux rootfs.

```sh
$ ./set-kernel.sh
$ ./set-arch-rootfs.sh
$ ./start-vm.sh
```

Cool this seems to be working:

```
...
[  OK  ] Reached target Multi-User System.
[  OK  ] Reached target Graphical Interface.

Arch Linux 4.14.55-84.37.amzn2.x86_64 (ttyS0)

firecracker-arch login:
```

So we are using the hello kernel we downloaded earlier, with our own Arch Linux
rootfs. We can login with root who has no password.

```
[root@firecracker-arch ~]# systemd-analyze 
Startup finished in 108ms (kernel) + 998ms (userspace) = 1.106s 
graphical.target reached after 995ms in userspace
[root@firecracker-arch ~]# top
top - 08:08:53 up 2 min,  1 user,  load average: 0.00, 0.00, 0.00
Tasks:  40 total,   1 running,  39 sleeping,   0 stopped,   0 zombie
%Cpu(s):  0.0 us,  0.0 sy,  0.0 ni,100.0 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :    112.3 total,     46.9 free,     21.4 used,     44.0 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.     85.3 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND  
      1 root      20   0   19496  10640   8520 S   0.0   9.3   0:00.21 systemd  
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.00 kthreadd 
      3 root      20   0       0      0      0 I   0.0   0.0   0:00.00 kworker+ 
      4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker+ 
      5 root      20   0       0      0      0 I   0.0   0.0   0:00.00 kworker+ 
      6 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 mm_perc+ 
      7 root      20   0       0      0      0 S   0.0   0.0   0:00.00 ksoftir+ 
      8 root      20   0       0      0      0 I   0.0   0.0   0:00.00 rcu_sch+ 
      9 root      20   0       0      0      0 I   0.0   0.0   0:00.00 rcu_bh   
     10 root      rt   0       0      0      0 S   0.0   0.0   0:00.00 migrati+ 
     11 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/0  
     12 root      20   0       0      0      0 S   0.0   0.0   0:00.00 kdevtmp+ 
     13 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 netns    
     14 root      20   0       0      0      0 I   0.0   0.0   0:00.00 kworker+ 
     23 root      20   0       0      0      0 I   0.0   0.0   0:00.01 kworker+ 
    132 root      20   0       0      0      0 S   0.0   0.0   0:00.00 oom_rea+ 
    133 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 writeba+ 
[root@firecracker-arch ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
[root@firecracker-arch ~]# df -ah
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       2.0G  769M  1.1G  42% /
devtmpfs         55M     0   55M   0% /dev
sysfs              0     0     0    - /sys
proc               0     0     0    - /proc
securityfs         0     0     0    - /sys/kernel/security
tmpfs            57M     0   57M   0% /dev/shm
devpts             0     0     0    - /dev/pts
tmpfs            57M  108K   57M   1% /run
tmpfs            57M     0   57M   0% /sys/fs/cgroup
cgroup2            0     0     0    - /sys/fs/cgroup/unified
cgroup             0     0     0    - /sys/fs/cgroup/systemd
pstore             0     0     0    - /sys/fs/pstore
bpf                0     0     0    - /sys/fs/bpf
cgroup             0     0     0    - /sys/fs/cgroup/perf_event
cgroup             0     0     0    - /sys/fs/cgroup/hugetlb
cgroup             0     0     0    - /sys/fs/cgroup/net_cls,net_prio
cgroup             0     0     0    - /sys/fs/cgroup/cpuset
cgroup             0     0     0    - /sys/fs/cgroup/freezer
cgroup             0     0     0    - /sys/fs/cgroup/cpu,cpuacct
cgroup             0     0     0    - /sys/fs/cgroup/devices
cgroup             0     0     0    - /sys/fs/cgroup/memory
cgroup             0     0     0    - /sys/fs/cgroup/pids
cgroup             0     0     0    - /sys/fs/cgroup/blkio
mqueue             0     0     0    - /dev/mqueue
hugetlbfs          0     0     0    - /dev/hugepages
debugfs            0     0     0    - /sys/kernel/debug
tmpfs            57M     0   57M   0% /tmp
tmpfs            12M     0   12M   0% /run/user/0
```

Ok that was easy. But wouldn't it be nice to have the Arch Linux kernel with
the Arch Linux rootfs? Lets download the latest package, extract that and boot.
Ah no that won't work, we need an uncompressed kernel so we need a script from
the Linux repository called [extract-vmlinux][14]. Actually there is no point
in trying the stock Arch Linux kernel since we will only get the vmlinuz file
and ext4 is built as a module so we will not be able to use our rootfs. We can
try another build where ext4 is built in.

```sh
$ curl -fsSL -O https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/scripts/extract-vmlinux
$ chmod +x extract-vmlinux
$ curl -fsSL -O http://repo.herecura.eu/herecura/x86_64/linux-bede-5.6.14-1-x86_64.pkg.tar.zst
$ tar -xf linux-bede-5.6.14-1-x86_64.pkg.tar.zst
$ ./extract-vmlinux usr/lib/modules/5.6.14-1-BEDE/vmlinuz > arch-vmlinux.bin
```

We will set the Arch kernel via a little helper
[set-arch-kernel.sh](./set-arch-kernel.sh) to test this.

```sh
$ ./start-firecracker.sh
```

```sh
$ ./set-arch-kernel.sh
$ ./set-arch-rootfs.sh
$ ./start-vm.sh
```

Ok that would have been too easy. The kernel can't seem to find the device of
our rootfs.

```
[    0.446354] VFS: Cannot open root device "vda" or unknown-block(0,0): error -6
[    0.447137] Please append a correct "root=" boot option; here are the available partitions:
[    0.447862] Kernel panic - not syncing: VFS: Unable to mount root fs on unknown-block(0,0)
[    0.448566] CPU: 0 PID: 1 Comm: swapper/0 Not tainted 5.6.14-1-BEDE #1
[    0.449113] Call Trace:
[    0.449329]  dump_stack+0x57/0x7a
[    0.449645]  panic+0xe6/0x2a4
[    0.449891]  ? printk+0x43/0x45
[    0.450164]  mount_block_root+0x279/0x302
[    0.450497]  mount_root+0x78/0x7b
[    0.450813]  prepare_namespace+0x13a/0x16b
[    0.451247]  kernel_init_freeable+0x20b/0x218
[    0.451610]  ? rest_init+0xa5/0xa5
[    0.451891]  kernel_init+0x9/0xfb
[    0.452166]  ret_from_fork+0x35/0x40
[    0.452476] Kernel Offset: disabled
[    0.452789] Rebooting in 1 seconds..
```

Ok next step; build an updated kernel based on the 4.14 config we can find in
the firecracker repo. For this we will create a `linux-firecracker` package
built with the Arch Linux toolchain. When converting the 4.14 config to 5.4.42
config we can answer No to most things. For reproducibility we offer the build
scripts and config [here](./linux-firecracker-5.4.42-1.src.tar.gz).

```sh
$ makepkg
==> Making package: linux-firecracker 5.4.42-1 (Thu 21 May 2020 10:33:18 AM CEST)
==> Checking runtime dependencies...
==> Checking buildtime dependencies...
==> Retrieving sources...
  -> Updating linux-stable git repo...
Fetching origin
  -> Found config-firecracker.x86_64
==> Validating source files with sha512sums...
    linux-stable ... Skipped
    config-firecracker.x86_64 ... Passed
==> Verifying source file signatures with gpg...
    linux-stable git repo ... Passed
==> Extracting sources...
  -> Creating working copy of linux-stable git repo...
Cloning into 'linux-stable'...
done.
Updating files: 100% (67975/67975), done.
Updating files: 100% (23032/23032), done.
Switched to a new branch 'makepkg'
==> Starting prepare()...
...
==> Leaving fakeroot environment.
==> Finished making: linux-firecracker 5.4.42-1 (Thu 21 May 2020 10:36:02 AM CEST)
```

We can try again to run Arch Linux rootfs with an Arch Linux compiled kernel.

```
$ tar -xf linux-firecracker-5.4.42-1-x86_64.pkg.tar.xz
$ ./extract-vmlinux usr/lib/modules/5.4.42-1-FIRECRACKER/vmlinuz > arch-vmlinux.bin
```

Lets run this again (crosses fingers).

```sh
$ ./start-firecracker.sh
```

```sh
$ ./set-arch-kernel.sh
$ ./set-arch-rootfs.sh
$ ./start-vm.sh
```

Victory !!!!

```
...
[  OK  ] Reached target Multi-User System.
[  OK  ] Reached target Graphical Interface.

Arch Linux 5.4.42-1-FIRECRACKER (ttyS0)

firecracker-arch login:
```

So lets see how it is doing now. Did we get similar results with this newer
kernel built on a completely up-to-date toolchain.

```
[root@firecracker-arch ~]# systemd-analyze 
Startup finished in 906ms (kernel) + 1.050s (userspace) = 1.956s 
graphical.target reached after 1.046s in userspace
[root@firecracker-arch ~]# top
top - 08:48:17 up 2 min,  1 user,  load average: 0.00, 0.00, 0.00
Tasks:  44 total,   1 running,  43 sleeping,   0 stopped,   0 zombie
%Cpu(s):  5.9 us,  5.9 sy,  0.0 ni, 88.2 id,  0.0 wa,  0.0 hi,  0.0 si,  0.0 st
MiB Mem :    111.0 total,     44.8 free,     21.7 used,     44.5 buff/cache
MiB Swap:      0.0 total,      0.0 free,      0.0 used.     83.7 avail Mem 

    PID USER      PR  NI    VIRT    RES    SHR S  %CPU  %MEM     TIME+ COMMAND  
      1 root      20   0   19476  10628   8516 S   0.0   9.4   0:00.24 systemd  
      2 root      20   0       0      0      0 S   0.0   0.0   0:00.00 kthreadd 
      3 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_gp   
      4 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 rcu_par+ 
      5 root      20   0       0      0      0 I   0.0   0.0   0:00.00 kworker+ 
      6 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 kworker+ 
      7 root      20   0       0      0      0 I   0.0   0.0   0:00.00 kworker+ 
      8 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 mm_perc+ 
      9 root      20   0       0      0      0 S   0.0   0.0   0:00.00 ksoftir+ 
     10 root      20   0       0      0      0 I   0.0   0.0   0:00.00 rcu_sch+ 
     11 root      rt   0       0      0      0 S   0.0   0.0   0:00.00 migrati+ 
     12 root      20   0       0      0      0 S   0.0   0.0   0:00.00 cpuhp/0  
     13 root      20   0       0      0      0 S   0.0   0.0   0:00.00 kdevtmp+ 
     14 root       0 -20       0      0      0 I   0.0   0.0   0:00.00 netns    
     15 root      20   0       0      0      0 S   0.0   0.0   0:00.03 kauditd  
     16 root      20   0       0      0      0 I   0.0   0.0   0:00.00 kworker+ 
     17 root      20   0       0      0      0 S   0.0   0.0   0:00.00 oom_rea+
[root@firecracker-arch ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
[root@firecracker-arch ~]# df -ah
Filesystem      Size  Used Avail Use% Mounted on
/dev/root       2.0G  769M  1.1G  42% /
devtmpfs         53M     0   53M   0% /dev
sysfs              0     0     0    - /sys
proc               0     0     0    - /proc
securityfs         0     0     0    - /sys/kernel/security
tmpfs            56M     0   56M   0% /dev/shm
devpts             0     0     0    - /dev/pts
tmpfs            56M  116K   56M   1% /run
tmpfs            56M     0   56M   0% /sys/fs/cgroup
cgroup2            0     0     0    - /sys/fs/cgroup/unified
cgroup             0     0     0    - /sys/fs/cgroup/systemd
none               0     0     0    - /sys/fs/bpf
cgroup             0     0     0    - /sys/fs/cgroup/hugetlb
cgroup             0     0     0    - /sys/fs/cgroup/cpu,cpuacct
cgroup             0     0     0    - /sys/fs/cgroup/devices
cgroup             0     0     0    - /sys/fs/cgroup/pids
cgroup             0     0     0    - /sys/fs/cgroup/blkio
cgroup             0     0     0    - /sys/fs/cgroup/freezer
cgroup             0     0     0    - /sys/fs/cgroup/perf_event
cgroup             0     0     0    - /sys/fs/cgroup/memory
cgroup             0     0     0    - /sys/fs/cgroup/net_cls,net_prio
cgroup             0     0     0    - /sys/fs/cgroup/cpuset
mqueue             0     0     0    - /dev/mqueue
hugetlbfs          0     0     0    - /dev/hugepages
debugfs            0     0     0    - /sys/kernel/debug
tmpfs            56M     0   56M   0% /tmp
tmpfs            12M     0   12M   0% /run/user/0
```

So it works but it is now twice as slow to startup, when we are using the older
amazon provided kernel the vm is booted in `1.106s`, with our custom built more
recent kernel we are at `1.956s`. Even though that is still not bad 2 seconds,
its a huge difference when we had around 1 second before.

## Networking

We still have no network connectivity so using this for single services is not
that useful at the moment. From the documentation we learn we have to create a
tap device on the host and attach our guest eth0 to it. Our host must be able
to NAT the network traffic from the guest to the outside world.

To set this up we have a simple script
[set-basic-networking.sh](./set-basic-networking.sh).

```sh
#!/usr/bin/env bash

tapdev="firecracker0"
guestnet="10.240.0.1/24"
guestgw="10.240.0.1"
guestip="10.240.0.11"

sudo ip link del ${tapdev} || true
sudo ip tuntap add ${tapdev} mode tap
sudo ip addr add ${guestnet} dev ${tapdev}
sudo ip link set ${tapdev} up
sudo iptables -t nat -A POSTROUTING -o wlp59s0 -j MASQUERADE
sudo iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
sudo iptables -A FORWARD -i ${tapdev} -o wlp59s0 -j ACCEPT

curl --unix-socket "$(pwd)"/firecracker.socket -i \
    -X PUT 'http://localhost/network-interfaces/eth0' \
    -H 'Accept: application/json'           \
    -H 'Content-Type: application/json'     \
    -d "{
          \"iface_id\": \"eth0\",
          \"guest_mac\": \"AA:BB:00:00:00:01\",
          \"host_dev_name\": \"${tapdev}\"
    }"

echo "Run the following in the guest:"
echo "ip addr add ${guestip} dev eth0"
echo "ip link set eth0 up"
echo "ip route add default via ${guestgw} dev eth0 onlink"
echo 'echo "nameserver 1.1.1.1" >> /etc/resolv.conf'
```

In the above we show that the routing will be done over the laptop's wireless
device.

Lets see if this gets everything working with networking and all.

```sh
$ ./start-firecracker.sh
```

```sh
$ ./set-arch-kernel.sh
$ ./set-arch-rootfs.sh
$ ./set-basic-networking.sh
$ ./start-vm.sh
```

On the host machine we now have a firecracker0 tap interface and hopefully we
will get the guest traffic to the outside world as well.

```sh
$ ip a
...
11: firecracker0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 92:48:39:83:60:c1 brd ff:ff:ff:ff:ff:ff
    inet 10.240.0.1/24 scope global firecracker0
       valid_lft forever preferred_lft forever
    inet6 fe80::9048:39ff:fe83:60c1/64 scope link 
       valid_lft forever preferred_lft forever
```

This works but we must manually set the ip address and bring the device up.

```sh
[root@firecracker-arch ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN group default qlen 1000
    link/ether aa:bb:00:00:00:01 brd ff:ff:ff:ff:ff:ff
[root@firecracker-arch ~]# ip addr add 10.240.0.11 dev eth0
[root@firecracker-arch ~]# ip link set eth0 up
[root@firecracker-arch ~]# ip route add default via 10.240.0.1 dev eth0 onlink
[root@firecracker-arch ~]# echo "nameserver 1.1.1.1" >> /etc/resolv.conf
[root@firecracker-arch ~]# ip a
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
    inet6 ::1/128 scope host 
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP group default qlen 1000
    link/ether aa:bb:00:00:00:01 brd ff:ff:ff:ff:ff:ff
    inet 10.240.0.11/32 scope global eth0
       valid_lft forever preferred_lft forever
    inet6 fe80::a8bb:ff:fe00:1/64 scope link 
       valid_lft forever preferred_lft forever
```

Can we ping our guest from the host?

```sh
$ ping 10.240.0.11
PING 10.240.0.11 (10.240.0.11) 56(84) bytes of data.
64 bytes from 10.240.0.11: icmp_seq=1 ttl=64 time=0.836 ms
64 bytes from 10.240.0.11: icmp_seq=2 ttl=64 time=0.240 ms
64 bytes from 10.240.0.11: icmp_seq=3 ttl=64 time=0.201 ms
^C
--- 10.240.0.11 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2083ms
rtt min/avg/max/mdev = 0.201/0.425/0.836/0.290 ms
```

Fantastic, now we must see to get information from the outside world into the
guest.

```sh
[root@firecracker-arch ~]# ping 1.1.1.1
PING 1.1.1.1 (1.1.1.1) 56(84) bytes of data.
64 bytes from 1.1.1.1: icmp_seq=1 ttl=57 time=15.4 ms
64 bytes from 1.1.1.1: icmp_seq=2 ttl=57 time=93.3 ms
64 bytes from 1.1.1.1: icmp_seq=3 ttl=57 time=14.9 ms

--- 1.1.1.1 ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 2006ms
rtt min/avg/max/mdev = 14.879/41.206/93.331/36.858 ms
[root@firecracker-arch ~]# curl -s -o /dev/null -D - https://herecura.eu
HTTP/2 200 
content-type: text/html; charset=UTF-8
date: Thu, 21 May 2020 09:11:00 GMT
etag: W/"5dae1122-145d"
last-modified: Mon, 21 Oct 2019 20:12:18 GMT
server: nginx/1.17.4
vary: Accept-Encoding

[root@firecracker-arch ~]# pacman -Sy 
:: Synchronizing package databases...
 core is up to date
 extra                1719.0 KiB  1066 KiB/s 00:02 [######################] 100%
 community               4.9 MiB  2.05 MiB/s 00:02 [######################] 100%
```

Great everything seems to work.

## Conclusion

Firecracker is a really nice piece of software. It is definitely fun to play
with. But to use it its a bit involved. We would need to manage firecracker
instances, setup networking "manually". We would probably need to write
wrappers to manage multiple vm's. Maybe `firectl` will be that piece of
software we need. For now, if we need to customize a lot of parts, we might be
able to just build a single purpose system with a slimmed down kernel that can
be run on regular virtualization implementations like qemu, libvirt or even
OpenStack or vmware.

[1]: https://firecracker-microvm.github.io/
[2]: https://www.rust-lang.org/
[3]: https://github.com/firecracker-microvm/firectl
[4]: https://github.com/firecracker-microvm/firecracker-containerd
[5]: https://ignite.readthedocs.io/en/stable/
[6]: https://katacontainers.io/
[7]: https://kubernetes.io/
[8]: https://containerd.io/
[9]: https://github.com/firecracker-microvm/firecracker/blob/master/docs/getting-started.md#getting-the-firecracker-binary
[10]: https://github.com/firecracker-microvm/firecracker/releases
[11]: https://alpinelinux.org/
[12]: https://github.com/firecracker-microvm/firecracker/blob/master/src/api_server/swagger/firecracker.yaml
[13]: https://www.archlinux.org/
[14]: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/scripts/extract-vmlinux
