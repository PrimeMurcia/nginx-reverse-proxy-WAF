# Install Nginx with ModSecurity 3 + OWASP CRS on Ubuntu

This guide explains how to install **Nginx** with **ModSecurity 3** and the **OWASP Core Rule Set (CRS)** on an **Ubuntu server**. ModSecurity is a Web Application Firewall (WAF) that protects web applications from common attack vectors like SQL injection, XSS, and more. OWASP CRS is a set of rules that helps to detect and block malicious requests.

## Prerequisites

- A **VPS** or server running **Ubuntu 20.04** or latest.
- **Root** or **sudo** access to the server.
- Basic knowledge of the command line.

---

## 1. Update the System and Install Required Libraries

Before beginning the installation, update the system and install necessary libraries.

```bash
sudo apt update && sudo apt upgrade -y
```
## Install libraries required for compiling ModSecurity:

```bash
sudo apt install gcc make build-essential autoconf automake libtool libcurl4-openssl-dev liblua5.3-dev libfuzzy-dev ssdeep gettext pkg-config libgeoip-dev libyajl-dev doxygen libpcre++-dev libpcre2-16-0 libpcre2-dev libpcre2-posix3 zlib1g zlib1g-dev -y
```

## 1. Install ModSecurity
Clone the ModSecurity repository and install it from source.

```bash

cd /opt && sudo git clone https://github.com/owasp-modsecurity/ModSecurity.git
cd ModSecurity
```

## Initialize and update the submodules:

```bash
sudo git submodule init
sudo git submodule update
```
## Build and install ModSecurity:

```bash
sudo ./build.sh
sudo ./configure
sudo make
sudo make install
```
## 3. Install ModSecurity-Nginx Connector
Download the ModSecurity-Nginx connector:

```bash
cd /opt && sudo git clone https://github.com/owasp-modsecurity/ModSecurity-nginx.git
```
## 4. Install Nginx
Add the Nginx Repository
Add the Nginx repository from Ondrej PPA to install the latest stable version:

```bash
sudo add-apt-repository ppa:ondrej/nginx -y
sudo apt update
```
## Install Nginx
Now, install Nginx:

```bash
sudo apt install nginx -y
```

## Enable Nginx to start on boot:

```bash
sudo systemctl enable nginx
sudo systemctl status nginx
```
## Check the installed Nginx version:
```bash
sudo nginx -v
```
## 5. Download Nginx Source Code
Download the Nginx source code that matches your installed version.

```bash
cd /opt && sudo wget https://nginx.org/download/nginx-X.Y.Z.tar.gz  # Replace X.Y.Z with your version
sudo tar -xzvf nginx-X.Y.Z.tar.gz
cd nginx-X.Y.Z
```
## 6. Build Nginx with ModSecurity
Configure and build Nginx with the ModSecurity module:
```bash
sudo ./configure --with-compat --add-dynamic-module=/opt/ModSecurity-nginx
sudo make
sudo make modules
```

## 7. Copy the Necessary Files
Copy the Nginx ModSecurity module and configuration files to the appropriate directories:

```bash
sudo cp objs/ngx_http_modsecurity_module.so /etc/nginx/modules-enabled/
sudo cp /opt/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsecurity.conf
sudo cp /opt/ModSecurity/unicode.mapping /etc/nginx/unicode.mapping
```
## 8. Enable ModSecurity in Nginx Configuration
Edit Nginx Configuration
Edit the nginx.conf file to load the ModSecurity module:

```bash
sudo nano /etc/nginx/nginx.conf
```
Add the following line in the http block:
```nginx
load_module /etc/nginx/modules-enabled/ngx_http_modsecurity_module.so;
```
## Enable ModSecurity for Server Block
Edit your site’s configuration (usually in sites-enabled/default):

```bash
sudo nano /etc/nginx/sites-enabled/default
```
## Add these lines inside the server block:

```nginx
modsecurity on;
modsecurity_rules_file /etc/nginx/modsecurity.conf;
```
## Modify ModSecurity Configuration
Edit ModSecurity’s configuration to enable the rules engine:

```bash
sudo nano /etc/nginx/modsecurity.conf
```
## Change SecRuleEngine to On:

```nginx
SecRuleEngine On
```
## 9. Test and Restart Nginx
Test the Nginx configuration for syntax errors:

```bash
sudo nginx -t
```
## If everything is okay, restart Nginx:

```bash
sudo systemctl restart nginx
```

## 10. Update ModSecurity Rules with OWASP CRS
Download OWASP CRS
Clone the OWASP Core Rule Set (CRS) repository to your Nginx configuration directory:

```bash
sudo git clone https://github.com/coreruleset/coreruleset.git /etc/nginx/owasp-crs
```
## Copy the Default Configuration
Copy the default CRS setup file:

```bash
sudo cp /etc/nginx/owasp-crs/crs-setup.conf{.example,}
```
## Update ModSecurity Configuration to Load CRS
Edit the ModSecurity configuration to include the CRS rules:

```bash
sudo nano /etc/nginx/modsecurity.conf
```
## Add the following lines at the end of the file:

```nginx
Include owasp-crs/crs-setup.conf
Include owasp-crs/rules/*.conf
```
## 11. Final Nginx Test and Restart
Test the Nginx configuration again:

```bash
sudo nginx -t
```
## Restart the Nginx service to apply the changes:

```bash
sudo service nginx restart
```
## 12. Test ModSecurity + Nginx
To test if ModSecurity and OWASP CRS are working correctly, try accessing your server with a malicious URL (for example, a PHP shell):

```bash
https://your_server_ip/as.php?s=/bin/bash
```
If everything is working correctly, you should see a 403 Forbidden response indicating that the request was blocked by ModSecurity.

## View Logs
You can view logs for more details on blocked requests:

```bash
sudo tail -f /var/log/modsec_audit.log
sudo tail -f /var/log/nginx/error.log
```

Conclusion
Congratulations! You have successfully installed Nginx with ModSecurity 3 and OWASP CRS on your Ubuntu server. Your server is now equipped with a robust web application firewall (WAF) to help protect against common attacks and vulnerabilities.

Customization
Nginx version: Replace the version in the wget command with the appropriate Nginx version you want to install.

Configuration adjustments: Modify the Nginx and ModSecurity configurations to suit your specific requirements (such as different server blocks, rules, or custom security settings).

Feel free to adjust the instructions according to your needs.


### Notes:
1. The version of Nginx is marked as `X.Y.Z` for the user to replace with the appropriate version they want to download.


