# Easyrsa

apt update
apt install easy-rsa
mkdir /etc/ca
cp -r /usr/share/easy-rsa /etc/ca
chown -R administrator:administrator /etc/ca 
chmod -R 700 /etc/ca
cd /etc/ca/easy-rsa
EASYRSA_PKI=ca ./easyrsa init-pki
EASYRSA_PKI=ca ./easyrsa build-ca
# Запросит данные, вводить следующее:
Enter New CA Key Passphrase: Cert
Re-Enter New CA Key Passphrase: Cert
Common Name (eg: your user, host, or server name): REA2026-CA
# Выполнить:
export EASYRSA_EXTRA_EXTS="subjectAltName=DNS:*.rea26.skills,DNS:*.rea26.ru"
EASYRSA_PKI=ca ./easyrsa --req-cn="*.rea26.skills" gen-req wildcard.rea26.skills nopass
# Запросит данные, вводить следующее:
Common Name (eg: your user, host, or server name): wildcard.rea26.skills
# Выполнить:
EASYRSA_PKI=ca ./easyrsa sign-req server wildcard.rea26.skills
# Запросит данные, вводить следующее:
Confirm request details: Yes
Enter pass phrase for ca/private/ca.key: Cert
# Выполнить:
EASYRSA_PKI=ca ./easyrsa gen-dh

# В результате выполнения указанных команд, если всё сделано корректно, создаются файлы:
# ca/dh.pem
# ca/ca.crt
# ca/issued/wildcard.rea26.skills.crt
# ca/private/ca.key
# ca/private/wildcard.rea26.skills.key

# Теперь необходимо перекинуть файлы на ISP-SRV по scp:
scp /etc/ca/easy-rsa/ca/ca.crt \
/etc/ca/easy-rsa/ca/issued/wildcard.rea26.skills.crt \
/etc/ca/easy-rsa/ca/private/wildcard.rea26.skills.key \
administrator@IP:/tmp # Вместо IP подставить IP ISP-SRV

# На ISP-SRV:
mv /tmp/ca.crt /usr/share/ca-certificates
dpkg-reconfigure ca-certificates # с помощью пробела выбрать ca.crt и дальше нажать на сохранение. В результате должны увидеть что-то вроде 1 added
mv /tmp/wildcard.rea26.skills.crt /etc/ssl/certs/wildcard.rea26.skills.crt
mv /tmp/wildcard.rea26.skills.key /etc/ssl/private/wildcard.rea26.skills.key

# На ВСЕ остальные устройства необходимо перекинуть только ca.crt:
scp /etc/ca/easy-rsa/ca/ca.crt administrator@IP:/tmp
# На устройствах, куда перекинули, выполнить:
mv /tmp/ca.crt /usr/share/ca-certificates \
dpkg-reconfigure ca-certificates # с помощью пробела выбрать ca.crt и дальше нажать на сохранение. В результате должны увидеть что-то вроде 1 added

---
# APACHE
# На ISP-SRV:
apt update
apt install apache
systemctl enable --now apache2
nano /etc/apache2/sites-available/isp.rea26.skills.conf # Вставить сюда конфиг из блока ниже по тексту
nano /etc/apache2/sites-available/isp.rea26.ru.conf # Вставить сюда конфиг из блока ниже по тексту
nano /etc/apache2/sites-available/repo.rea26.skills.conf # Вставить сюда конфиг из блока ниже по тексту
mkdir -p /var/www/html/skills
mkdir -p /var/www/html/ru
mkdir -p /var/www/repo/reaskills
mkdir -p /var/www/repo/reasklills-app
nano /var/www/html/ru/index.html # Написать <H1>Hello from Internet</H1>
nano /var/www/html/skills/index.html # Написать <H1>Hello from Office</H1>
nano /var/www/repo/reaskills/Packages # Вставить сюда текст из блока ниже по тексту
cp /var/www/repo/reasklills/Packages /var/www/repo/reaskills-apps/Packages
cd /tmp
# Затем скачать страничку 404.html с files и поместить её в /tmp
cp 404.html /var/www/html/ru/404.html
cp 404.html /var/www/html/skills/404.html
cp 404.html /var/www/repo/404.html
htpasswd -c /etc/apache2/htpasswd.isp.rea26.skills mikhalych # Предложит ввести пароль. Необходимо ввести dr0wss@P
a2enmod ssl
cd /etc/apache2/sites-available/
a2ensite isp.rea26.ru.conf
a2ensite isp.rea26.skills.conf
a2ensite repo.rea26.skills.conf
systemctl restart apache2


####################### КОНФИГИ ##############
# Конфиг для isp.rea26.skills.conf
<VirtualHost *:80>
        ServerName isp.rea26.skills
        Redirect permanent / https://isp.rea26.skills/
</VirtualHost>

<VirtualHost *:443>
        ServerName isp.rea26.skills
        DocumentRoot /var/www/html/skills

        ErrorDocument 404 /404.html

        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/wildcard.rea26.skills.crt
        SSLCertificateKeyFile /etc/ssl/private/wildcard.rea26.skills.key

        <Location /secret>
                AuthType Basic
                AuthName "Restricted Access"
                AuthUserFile /etc/apache2/htpasswd.isp.rea26.skills
                Require valid-user
        </Location>
</VirtualHost>

####################### КОНФИГИ ##############
# Конфиг для isp.rea26.ru.conf
<VirtualHost *:80>
        ServerName isp.rea26.ru
        Redirect permanent / https://isp.rea26.ru/
</VirtualHost>

<VirtualHost *:443>
        ServerName isp.rea26.ru
        DocumentRoot /var/www/html/ru

        ErrorDocument 404 /404.html

        SSLEngine on
        SSLCertificateFile /etc/ssl/certs/wildcard.rea26.skills.crt
        SSLCertificateKeyFile /etc/ssl/private/wildcard.rea26.skills.key

        <Location /secret>
                AuthType Basic
                AuthName "Restricted Access"
                AuthUserFile /etc/apache2/htpasswd.isp.rea26.skills
                Require valid-user
        </Location>
</VirtualHost>
####################### КОНФИГИ ##############
# Конфиг для repo.rea26.skills
<VirtualHost *:80>
    ServerName repo.rea26.skills
    Redirect permanent / https://repo.rea26.skills/
</VirtualHost>

<VirtualHost *:443>
    ServerName repo.rea26.skills
    DocumentRoot /var/www/repo

    <Directory /var/www/repo>
        Options Indexes FollowSymLinks
        AllowOverride None
        Require all granted
    </Directory>

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/wildcard.rea26.skills.crt
    SSLCertificateKeyFile /etc/ssl/private/wildcard.rea26.skills.key

    ErrorDocument 404 /404.html
</VirtualHost>
####################### КОНФИГИ ##############
# Конфиг файла /var/www/repo/reaskills/Packages
Package: reaskills-today
Version: 1.0-2026
Section: misc
Priority: optional
Architecture: amd64
Maintainer: Ваше Имя <you@example.com>
Description: Этот пакет показывает сегодняшний день и напоминает, что завтра дедлайн.
