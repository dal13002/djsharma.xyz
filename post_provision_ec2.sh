#! /bin/bash

# update base os
sudo yum update -y

# docker install / start 
sudo amazon-linux-extras install docker -y
sudo service docker start

# Fix permissions; this requires reboot, so we won't do it for POC
#sudo usermod -a -G docker ec2-user

# git install / pull app repo
sudo yum install git -y

# nginx config
mkdir /nginx
touch /nginx/server.crt
touch /nginx/server.key
touch /nginx/ca.crt
cat <<EOT >> /nginx/nginx.conf
server {
    listen              443 ssl;
    server_name         djsharma.xyz;
    ssl_certificate     /etc/nginx/server.crt;
    ssl_certificate_key /etc/nginx/server.key;
    ssl_protocols       TLSv1.2 TLSv1.3;
    ssl_client_certificate /etc/nginx/ca.crt;
    ssl_verify_client      optional;

    location / {
      if ($ssl_client_verify != SUCCESS) {
        return 403;
      }
      return 200 'hit server';
      #proxy_pass      http://127.0.0.1:3000;
    }
}
EOT

# make sure nginx runs on reboots
## TODO::

# run the docker container for nginx
# NOTE- files will be blank at first, and will need to be restarted
sudo docker run --name nginx-container \
-v /nginx/nginx.conf:/etc/nginx/nginx.conf:ro \
-v /nginx/server.crt:/etc/nginx/server.crt \
-v /nginx/server.key:/etc/nginx/server.key \
-v /nginx/ca.crt:/etc/nginx/ca.crt \
-p 443:80 -d nginx:latest
