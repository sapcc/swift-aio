#!/bin/sh

set -e

# Test require XFS mounted filesytem to test extended attributs
sudo truncate -s 1GB /srv/swift-tmp
sudo mkfs.xfs -f /srv/swift-tmp

sudo mkdir -p /mnt/tmp
sudo mount -o loop,noatime /srv/swift-tmp /mnt/tmp
sudo chown swift:swift /mnt/tmp

/swift/bin/prepare.sh
