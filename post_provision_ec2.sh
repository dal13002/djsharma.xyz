#! /bin/bash

# update base os
sudo yum update -y

# docker install / start 
sudo amazon-linux-extras install docker -y
sudo service docker start

# Fix permissions; this requires reboot, so we will still keep using "sudo" infront of docker for POC
sudo usermod -a -G docker ec2-user

# Make app directory
mkdir /home/ec2-user/app

# git install / pull app repo
sudo yum install git -y
cd /home/ec2-user/app && git clone https://github.com/dal13002/djsharma.xyz.git

# make ssl keys for cloudflare
openssl req -x509 -nodes -newkey rsa:4096 -keyout key.pem -out cert.pem -days 730 -subj '/CN=djsharma.xyz'

# make the nginx config file
cat <<EOT >> /home/ec2-user/app/nginx.conf
events {
  worker_connections  1024;
}
http {
  server {
      listen              443 ssl;
      server_name         djsharma.xyz;
      ssl_certificate     /etc/nginx/server.crt;
      ssl_certificate_key /etc/nginx/server.key;
      ssl_protocols       TLSv1.2 TLSv1.3;

      location / {
        include  /etc/nginx/mime.types;
      }
  }
}
EOT

# make sure nginx runs on reboots
## TODO::

# run the nginx docker container mounting app, certs, and config
sudo docker run --name nginx-container \
-v /home/ec2-user/app/nginx.conf:/etc/nginx/nginx.conf:ro \
-v /home/ec2-user/app/cert.pem:/etc/nginx/server.crt \
-v /home/ec2-user/app/key.pem:/etc/nginx/server.key \
-v  /home/ec2-user/app/djsharma.xyz/app/:/etc/nginx/html/ \
-p 443:443 -d nginx:latest
