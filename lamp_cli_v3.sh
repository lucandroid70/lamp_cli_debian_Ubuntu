#!/bin/bash

##### LANCIARE PER FORZA CON            sudo bash lamp_cli_v3.sh   #################################



set -x

# Aggiornamento e installazione dei pacchetti
sudo apt update
sudo apt upgrade -y
#sudo apt install build-essential bind9 curl avahi-daemon apache2 mariadb-server php libapache2-mod-php php-mysql phpmyadmin -y

#sudo apt install build-essential curl avahi-daemon apache2 mariadb-server php php-curl php-json php-cgi libapache2-mod-php php-mysql phpmyadmin -y


sudo apt install curl avahi-daemon apache2 mariadb-server php php-curl php-json php-cgi libapache2-mod-php -y


# Abilitazione dei moduli di Apache
sudo a2enmod rewrite
sudo a2enmod ssl

# Abilitazione dei siti predefiniti di Apache
sudo a2ensite default-ssl.conf
sudo a2ensite 000-default.conf

# Riavvio di Apache per applicare le modifiche
sudo systemctl reload apache2
sudo systemctl restart apache2

# Avvio di MariaDB
sudo systemctl start mariadb

# Sicurezza dell'installazione di MariaDB
sudo mysql_secure_installation


sudo apt install php-mysql phpmyadmin -y


# Configurazione dei virtual host (cmabia i nomi con i tuoi lasciando sempre le ""!) 
declare -a vhost_names=("www.nomesito.com" "www.nomesito.net" "www.nomesito.it" "www.altronomesito.com" "www.altronomesito.net" "www.altronomesito.org" "www.luca.com" "www.luca.net" "www.luca.org")

for vhost_name in "${vhost_names[@]}"; do
  # Creazione della directory del virtual host
  sudo mkdir -p /var/www/html/$vhost_name

  # Assegnazione dei permessi alla directory del virtual host
  sudo chown -R www-data:www-data /var/www/html/$vhost_name
  
  sudo chmod -R 755 /var/www/html/$vhost_name 

  # Creazione del file di configurazione del virtual host per HTTPS
  sudo bash -c "cat <<EOF > /etc/apache2/sites-available/$vhost_name-ssl.conf
<IfModule mod_ssl.c>
  <VirtualHost 192.168.0.180:443>
    ServerName $vhost_name
    ServerAlias www.$vhost_name
    DocumentRoot /var/www/html/$vhost_name
    ErrorLog \${APACHE_LOG_DIR}/$vhost_name-ssl-error.log
    CustomLog \${APACHE_LOG_DIR}/$vhost_name-ssl-access.log combined
    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/$vhost_name.crt
    SSLCertificateKeyFile /etc/ssl/private/$vhost_name.key
    <Directory /var/www/html/$vhost_name>
      AllowOverride All
      Require all granted
    </Directory>
  </VirtualHost>
</IfModule>
EOF"

  # Abilitazione del virtual host per HTTPS
  sudo a2ensite $vhost_name-ssl.conf

  # Generazione dei certificati SSL per il virtual host
  sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/$vhost_name.key -out /etc/ssl/certs/$vhost_name.crt -subj "/C=IT/ST=Lazio/L=Rome/O=Organization/OU=Department/CN=$vhost_name"
done


# Abilitazione dei moduli di Apache
sudo a2enmod rewrite
sudo a2enmod ssl

# Abilitazione dei siti predefiniti di Apache
sudo a2ensite default-ssl.conf
sudo a2ensite 000-default.conf

# Riavvio di Apache per applicare le modifiche
sudo systemctl reload apache2
sudo systemctl restart apache2

# Riavvio di Apache per applicare le modifiche
# sudo systemctl reload apache2

# Configurazione di BIND9 per i domini
#sudo bash -c "cat <<EOF > /etc/bind/named.conf.local
#$(for vhost_name in "${vhost_names[@]}"; do
#echo "zone \"$vhost_name\" {
#    type master;
#    file \"/etc/bind/zones/$vhost_name.zone\";
#};
#";
#done)
#EOF"

# Creazione delle directory delle zone
#for vhost_name in "${vhost_names[@]}"; do
#  sudo mkdir -p /etc/bind/zones
#done

# Creazione dei file di zona
#for vhost_name in "${vhost_names[@]}"; do
#  sudo bash -c "cat <<EOF > /etc/bind/zones/$vhost_name.zone
#\$TTL 86400
#@       IN      SOA     ns1.$vhost_name. admin.$vhost_name. (
 #                           2023062501 ; Serial
  #                          3600       ; Refresh
   #                         1800       ; Retry
    #                        604800     ; Expire
     #                       86400      ; Minimum TTL
   #                  )
#@       IN      NS      ns1.$vhost_name.
#@       IN      A       192.168.0.112
#www     IN      A       192.168.0.112
#EOF"
#done

# Riavvio di BIND9 per applicare le modifiche
#sudo systemctl restart bind9

# Riavvio di Apache per applicare le modifiche
#sudo systemctl restart apache2
