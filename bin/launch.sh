#!/bin/sh

set -e

swift-init all start

sudo tail -f /var/log/swift/*
