#!/bin/sh

set -e

sudo service rsync start

sudo truncate -s 1GB /srv/swift-disk

remakerings
resetswift
