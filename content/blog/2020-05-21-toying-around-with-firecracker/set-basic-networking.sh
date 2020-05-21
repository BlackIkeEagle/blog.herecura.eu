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
