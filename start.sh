#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo "run as root"
  exit 1
fi

if [ ! -f 'tinyproxy.conf' ]; then
  echo "Where is tinyproxy.conf??? Exiting."
  exit 1
fi

PACKAGE="tinyproxy"

if ! dpkg -l | grep -q "^ii $PACKAGE "; then
  echo "Installing $PACKAGE first"
  apt update -y
  apt install -y $PACKAGE
fi

cp tinyproxy.conf /etc/tinyproxy/

if ! systemctl is-enabled 'tinyproxy' &>/dev/null; then
  systemctl enable tinyproxy
fi

curl -sL https://www.dumbpipe.dev/install.sh | sh

./dumbpipe listen-tcp --host localhost:8888 &

./reverse-proxy &
