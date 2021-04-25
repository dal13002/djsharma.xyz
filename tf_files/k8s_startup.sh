#! /bin/bash

# update base os and get git
apt-get update -y && apt-get install git -y

# make certs
openssl req -x509 -nodes -newkey rsa:4096 -keyout /etc/nginx/server.key -out /etc/nginx/server.crt -days 730 -subj '/CN=djsharma.xyz'

# create directory / clone the repo
mkdir -p /etc/nginx/html
git clone https://github.com/dal13002/djsharma.xyz.git /tmp
mv /tmp/app/* /etc/nginx/html/
