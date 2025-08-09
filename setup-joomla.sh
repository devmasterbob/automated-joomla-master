#!/bin/bash

echo "Starte Joomla Setup..."

# Warten bis MySQL bereit ist
echo "Warte auf MySQL..."
while ! php -r "
try {
    \$pdo = new PDO('mysql:host=$JOOMLA_DB_HOST', '$JOOMLA_DB_USER', '$JOOMLA_DB_PASSWORD');
    echo 'MySQL Verbindung erfolgreich!';
    exit(0);
} catch (Exception \$e) {
    exit(1);
}
"; do
    sleep 2
done

# Überprüfen ob Joomla bereits installiert ist
if [ -f "/var/www/html/configuration.php" ]; then
    echo "Joomla ist bereits installiert."
    exit 0
fi

echo "Starte automatische Joomla Installation..."

# Joomla CLI Installation - korrekte Parameter für Joomla 6
cd /var/www/html

# Erstelle die configuration.php direkt
cat > configuration.php << EOF
<?php
class JConfig {
    public \$offline = '0';
    public \$offline_message = 'This site is down for maintenance.<br />Please check back again soon.';
    public \$display_offline_message = '1';
    public \$offline_image = '';
    public \$sitename = '$JOOMLA_SITE_NAME';
    public \$editor = 'tinymce';
    public \$captcha = '0';
    public \$list_limit = '20';
    public \$access = '1';
    public \$debug = '0';
    public \$debug_lang = '0';
    public \$debug_lang_const = '1';
    public \$dbtype = '$JOOMLA_DB_TYPE';
    public \$host = '$JOOMLA_DB_HOST';
    public \$user = '$JOOMLA_DB_USER';
    public \$password = '$JOOMLA_DB_PASSWORD';
    public \$db = '$JOOMLA_DB_NAME';
    public \$dbprefix = '$JOOMLA_DB_PREFIX';
    public \$live_site = '';
    public \$secret = '$(openssl rand -hex 16)';
    public \$gzip = '0';
    public \$error_reporting = 'default';
    public \$helpurl = 'https://help.joomla.org/proxy?keyref=Help{major}{minor}:{keyref}&lang={langcode}';
    public \$ftp_host = '';
    public \$ftp_port = '';
    public \$ftp_user = '';
    public \$ftp_pass = '';
    public \$ftp_root = '';
    public \$ftp_enable = '0';
    public \$offset = 'UTC';
    public \$mailonline = '1';
    public \$mailer = 'mail';
    public \$mailfrom = '$JOOMLA_ADMIN_EMAIL';
    public \$fromname = '$JOOMLA_SITE_NAME';
    public \$sendmail = '/usr/sbin/sendmail';
    public \$smtpauth = '0';
    public \$smtpuser = '';
    public \$smtppass = '';
    public \$smtphost = 'localhost';
    public \$smtpsecure = 'none';
    public \$smtpport = '25';
    public \$caching = '0';
    public \$cache_handler = 'file';
    public \$cachetime = '15';
    public \$cache_platformprefix = '0';
    public \$MetaDesc = '';
    public \$MetaKeys = '';
    public \$MetaTitle = '1';
    public \$MetaAuthor = '1';
    public \$MetaVersion = '0';
    public \$robots = '';
    public \$sef = '1';
    public \$sef_rewrite = '0';
    public \$sef_suffix = '0';
    public \$unicodeslugs = '0';
    public \$feed_limit = '10';
    public \$feed_email = 'none';
    public \$log_path = '/var/www/html/logs';
    public \$tmp_path = '/var/www/html/tmp';
    public \$lifetime = '15';
    public \$session_handler = 'database';
    public \$shared_session = '0';
}
EOF

# Datenbank installieren mit PHP-Skript
echo "Installiere Joomla Datenbank..."
php /tmp/install-joomla-db.php

# Installation Directory entfernen
if [ -d "/var/www/html/installation" ]; then
    rm -rf /var/www/html/installation
    echo "Installation Directory wurde entfernt."
fi

# Berechtigungen setzen
chown -R www-data:www-data /var/www/html/
chmod -R 755 /var/www/html/

echo "Joomla Installation abgeschlossen!"
