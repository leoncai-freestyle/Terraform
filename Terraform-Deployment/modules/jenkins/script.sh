#!/bin/bash

# sleep until instance is ready
until [[ -f /var/lib/cloud/instance/boot-finished ]]; do
  sleep 1
done

# install nginx
#apt-get update

while PID=$(pidof -s apt-get); do tail --pid=$PID -f /dev/null; done

apt-get  install nginx -y

# make sure nginx is started
service nginx start

