#! /bin/bash

# update and install nginx
sudo apt update -y
sudo apt install nginx -y

# set up the firewall
sudo ufw default allow outgoing
sudo ufw default deny incoming
sudo ufw allow ssh
sudo ufw allow from 103.21.244.0/22 to any port 443
sudo ufw allow from 103.22.200.0/22 to any port 443
sudo ufw allow from 103.31.4.0/22 to any port 443
sudo ufw allow from 104.16.0.0/13 to any port 443
sudo ufw allow from 104.24.0.0/14 to any port 443
sudo ufw allow from 108.162.192.0/18 to any port 443
sudo ufw allow from 131.0.72.0/22 to any port 443
sudo ufw allow from 141.101.64.0/18 to any port 443
sudo ufw allow from 162.158.0.0/15 to any port 443
sudo ufw allow from 172.64.0.0/13 to any port 443
sudo ufw allow from 173.245.48.0/20 to any port 443
sudo ufw allow from 188.114.96.0/20 to any port 443
sudo ufw allow from 190.93.240.0/20 to any port 443
sudo ufw allow from 197.234.240.0/22 to any port 443
sudo ufw allow from 198.41.128.0/17 to any port 443

# start the firewall
echo "y" | sudo ufw enable

# get the app
mkdir /home/adminuser/app
git clone https://github.com/dal13002/djsharma.xyz.git /home/adminuser/app

# move the static files
sudo rm -f /var/www/html/index.nginx-debian.html 
sudo mv /home/adminuser/app/app/* /var/www/html/

# certs
sudo openssl req -x509 -nodes -newkey rsa:4096 -keyout /etc/nginx/server.key -out /etc/nginx/server.crt -days 730 -subj '/CN=djsharma.xyz'

# set up nginx config
sudo bash -c "cat <<EOT > /etc/nginx/nginx.conf
events {
  worker_connections  1024;
}
http {
  server {
      root                /var/www/html;
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
EOT"

# make sure nginx runs on reboots
## TODO::

# nginx reload
sudo systemctl reload nginx
