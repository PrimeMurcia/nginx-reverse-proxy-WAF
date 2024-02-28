#!/bin/bash

# Step 1: Install Nginx on Debian/Ubuntu
sudo apt update
sudo apt install -y nginx

# Note: ModSecurity integrates with Nginx as a dynamic module, requiring the Nginx binary to be compiled with the --with-compat argument.

# Check Nginx configure arguments
sudo nginx -V

# Enable source code repository
sudo apt install -y software-properties-common
sudo apt-add-repository -ss
sudo apt update

# Step 2: Download Nginx Source Package
sudo chown $USER:$USER /usr/local/src/ -R
mkdir -p /usr/local/src/nginx
cd /usr/local/src/nginx/
sudo apt install -y dpkg-dev
sudo apt source nginx

# Check out the source code files
ls

# Step 3: Install libmodsecurity3
sudo apt install -y git
git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity /usr/local/src/ModSecurity/
cd /usr/local/src/ModSecurity/
sudo apt install -y gcc make build-essential autoconf automake libtool libcurl4-openssl-dev liblua5.3-dev libpcre2-dev libfuzzy-dev ssdeep gettext pkg-config libpcre3 libpcre3-dev libxml2 libxml2-dev libcurl4 libgeoip-dev libyajl-dev doxygen
git submodule init
git submodule update
./build.sh 
./configure
make -j8
sudo make install

# Step 4: Download and Compile ModSecurity v3 Nginx Connector Source Code
git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /usr/local/src/ModSecurity-nginx/
cd /usr/local/src/nginx/nginx-1.18.0/
sudo apt build-dep nginx
sudo apt install -y uuid-dev
sudo ./configure --with-compat --with-openssl=/usr/include/openssl/ --add-dynamic-module=/usr/local/src/ModSecurity-nginx
sudo make modules
sudo cp objs/ngx_http_modsecurity_module.so /usr/share/nginx/modules/

# Step 5: Load the ModSecurity v3 Nginx Connector Module
sudo nano /etc/nginx/nginx.conf
echo "load_module modules/ngx_http_modsecurity_module.so;" | sudo tee -a /etc/nginx/nginx.conf
echo "modsecurity on;" | sudo tee -a /etc/nginx/nginx.conf
echo "modsecurity_rules_file /etc/nginx/modsec/main.conf;" | sudo tee -a /etc/nginx/nginx.conf

sudo mkdir /etc/nginx/modsec/
sudo cp /usr/local/src/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
sudo nano /etc/nginx/modsec/modsecurity.conf

# (Update configuration file as needed)

# Test Nginx configuration
sudo nginx -t
sudo systemctl restart nginx

# Step 6: Enable OWASP Core Rule Set
wget https://github.com/coreruleset/coreruleset/archive/v4.0.0.tar.gz
tar xvf v4.0.0.tar.gz
sudo mv coreruleset-4.0.0/ /etc/nginx/modsec/
sudo mv /etc/nginx/modsec/coreruleset-4.0.0/crs-setup.conf.example /etc/nginx/modsec/coreruleset-4.0.0/crs-setup.conf
sudo nano /etc/nginx/modsec/main.conf

# Add the following lines:
# Include /etc/nginx/modsec/coreruleset-4.0.0/crs-setup.conf
# Include /etc/nginx/modsec/coreruleset-4.0.0/rules/*.conf

# Test Nginx configuration
sudo nginx -t
sudo systemctl restart nginx

# Step 7: Configure Nginx as a Reverse Proxy
sudo nano /etc/nginx/sites-available/your_domain

# Add the following configuration block:
# server {
#     listen 80 default_server;
#     listen [::]:80 default_server;
#
#     server_name yourdomain.com;
#
#     location / {
#         proxy_pass http://ip_address:port_number;
#         proxy_set_header Host $host;
#     }
# }

sudo unlink /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/your_domain /etc/nginx/sites-enabled/your_domain
sudo systemctl restart nginx
