# Secure ModSecurity Installation with Nginx on Debian/Ubuntu and Nginx Reserve Proxy

## Step 1: Install Nginx on Debian/Ubuntu 22

```bash
sudo apt install nginx
```

**Note:**
ModSecurity integrates with Nginx as a dynamic module, requiring the Nginx binary to be compiled with the `--with-compat` argument. Ensure your Nginx binary supports dynamic modules.

Check Nginx configure arguments:

```bash
sudo nginx -V
```

All Nginx binaries in the PPA are compiled with the `--with-compat` argument.

Enable source code repository:

```bash
sudo apt install software-properties-common
sudo apt-add-repository -ss
sudo apt update
```

## Step 2: Download Nginx Source Package

Create a directory for Nginx source code:

```bash
sudo chown username:username /usr/local/src/ -R
mkdir -p /usr/local/src/nginx
cd /usr/local/src/nginx/
sudo apt install dpkg-dev
sudo apt source nginx
```
Check out the source code files

```bash
ls
```

Sample files

```bash
nginx-1.18.0
nginx_1.18.0-6ubuntu14.4.debian.tar.xz
nginx_1.18.0-6ubuntu14.4.dsc
nginx_1.18.0.orig.tar.gz
```

## Step 3: Install libmodsecurity3

Clone ModSecurity source code from Github:

```bash
sudo apt install git
git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity /usr/local/src/ModSecurity/
cd /usr/local/src/ModSecurity/
sudo apt install gcc make build-essential autoconf automake libtool libcurl4-openssl-dev liblua5.3-dev libpcre2-dev libfuzzy-dev ssdeep gettext pkg-config libpcre3 libpcre3-dev libxml2 libxml2-dev libcurl4 libgeoip-dev libyajl-dev doxygen
git submodule init
git submodule update
./build.sh 
./configure
make -j8
sudo make install
```

Note: make -j8 base on your cpu count 

## Step 4: Download and Compile ModSecurity v3 Nginx Connector Source Code

Clone the ModSecurity v3 Nginx Connector Git repository:

```bash
git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git /usr/local/src/ModSecurity-nginx/
cd /usr/local/src/nginx/nginx-1.18.0/
sudo apt build-dep nginx
sudo apt install uuid-dev
sudo ./configure --with-compat --with-openssl=/usr/include/openssl/ --add-dynamic-module=/usr/local/src/ModSecurity-nginx
sudo make modules
sudo cp objs/ngx_http_modsecurity_module.so /usr/share/nginx/modules/
```

## Step 5: Load the ModSecurity v3 Nginx Connector Module

Edit the main Nginx configuration file:

```bash
sudo nano /etc/nginx/nginx.conf
```

Add the following line at the beginning of the file:

```plaintext
load_module modules/ngx_http_modsecurity_module.so;
modsecurity on;
modsecurity_rules_file /etc/nginx/modsec/main.conf;
```

Create the /etc/nginx/modsec/ directory:

```bash
sudo mkdir /etc/nginx/modsec/
sudo cp /usr/local/src/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf
sudo nano /etc/nginx/modsec/modsecurity.conf
```

Update the configuration file as needed and create /etc/nginx/modsec/main.conf.

Test Nginx configuration:

```bash
sudo nginx -t
sudo systemctl restart nginx
```

## Step 6: Enable OWASP Core Rule Set

Download the latest OWASP CRS from GitHub:

```bash
wget https://github.com/coreruleset/coreruleset/archive/v4.0.0.tar.gz
tar xvf v4.0.0.tar.gz
sudo mv coreruleset-4.0.0/ /etc/nginx/modsec/
sudo mv /etc/nginx/modsec/coreruleset-4.0.0/crs-setup.conf.example /etc/nginx/modsec/coreruleset-4.0.0/crs-setup.conf
sudo nano /etc/nginx/modsec/main.conf
```

Add the following lines:

```plaintext
Include /etc/nginx/modsec/coreruleset-4.0.0/crs-setup.conf
Include /etc/nginx/modsec/coreruleset-4.0.0/rules/*.conf
```

Test Nginx configuration:

```bash
sudo nginx -t
sudo systemctl restart nginx
```

## Step 7: Step 7: Configure Nginx as a Reverse Proxy

Edit the Nginx configuration file to set up a reverse proxy:


```bash
sudo nano /etc/nginx/sites-available/yourdomain
```

```bash
server {
        listen 80 default_server;
        listen [::]:80 default_server;

        server_name yourdomain.com;

        location / {
                proxy_pass http://ip address:port number;
                proxy_set_header Host $host;
        }
}
```

```bash
sudo unlink /etc/nginx/sites-enabled/default
sudo ln -s /etc/nginx/sites-available/your_domain /etc/nginx/sites-enabled/yourdomain
sudo systemctl restart nginx
```
