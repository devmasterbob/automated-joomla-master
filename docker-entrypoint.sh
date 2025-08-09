#!/bin/bash
set -euo pipefail

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
local var="$1"
local fileVar="${var}_FILE"
local def="${2:-}"
if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
joomla_error "Both $var and $fileVar are set (but are exclusive)"
fi
local val="$def"
if [ "${!var:-}" ]; then
val="${!var}"
elif [ "${!fileVar:-}" ]; then
val="$(< "${!fileVar}")"
fi
export "$var"="$val"
unset "$fileVar"
}

joomla_error() {
echo >&2 "ERROR: $*"
exit 1
}

# allow the container to be started with `--user`
if [[ "$1" == apache2* ]] && [ "$(id -u)" = '0' ]; then
exec gosu www-data "$0" "$@"
fi

# Database variables
file_env 'JOOMLA_DB_HOST' 'db'
file_env 'JOOMLA_DB_USER' "${MYSQL_USER:-root}"
file_env 'JOOMLA_DB_PASSWORD' "${MYSQL_PASSWORD:-${MYSQL_ROOT_PASSWORD:-}}"
file_env 'JOOMLA_DB_NAME' "${MYSQL_DATABASE:-joomla}"

if [ -z "$JOOMLA_DB_PASSWORD" ]; then
joomla_error 'missing required JOOMLA_DB_PASSWORD environment variable (or the MYSQL_ROOT_PASSWORD environment variable)'
fi

# Wait for database
echo "Waiting for database connection..."
until mysql -h"$JOOMLA_DB_HOST" -u"$JOOMLA_DB_USER" -p"$JOOMLA_DB_PASSWORD" -e "SELECT 1" &>/dev/null; do
echo "Database not ready, waiting..."
sleep 3
done
echo "Database connection established!"

# If /var/www/html is empty, populate it from /usr/src/joomla
if [ ! -e index.php ]; then
echo "Joomla not found in $PWD - copying from /usr/src/joomla..."
if [ "$(ls -A)" ]; then
echo "WARNING: $PWD is not empty - might have unexpected behavior"
fi

# Use cp instead of tar to avoid permission issues
cp -R /usr/src/joomla/* /usr/src/joomla/.[^.]* . 2>/dev/null || cp -R /usr/src/joomla/* .
chown -R www-data:www-data .
echo "Complete! Joomla has been successfully copied to $PWD"
fi

# Check for configuration file
if [ ! -e configuration.php ]; then
echo "Creating and populating the database..."
php /makedb.php "$JOOMLA_DB_HOST" "$JOOMLA_DB_USER" "$JOOMLA_DB_PASSWORD" "$JOOMLA_DB_NAME" "${JOOMLA_DB_PREFIX:-#__}" mysqli

echo "Writing configuration.php and additional setup ..."

# Create configuration.php
cat > configuration.php <<-EOF
<?php
class JConfig {
public \$offline = '0';
public \$offline_message = 'This site is down for maintenance.<br />Please check back again soon.';
public \$display_offline_message = '1';
public \$offline_image = '';
public \$sitename = '${JOOMLA_SITE_NAME:-Joomla Site}';
public \$editor = 'tinymce';
public \$captcha = '0';
public \$list_limit = '20';
public \$access = '1';
public \$debug = '0';
public \$debug_lang = '0';
public \$debug_lang_const = '1';
public \$dbtype = 'mysqli';
public \$host = '$JOOMLA_DB_HOST';
public \$user = '$JOOMLA_DB_USER';
public \$password = '$JOOMLA_DB_PASSWORD';
public \$db = '$JOOMLA_DB_NAME';
public \$dbprefix = '${JOOMLA_DB_PREFIX:-#__}';
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
public \$mailfrom = '${JOOMLA_ADMIN_EMAIL:-admin@example.com}';
public \$fromname = '${JOOMLA_SITE_NAME:-Joomla Site}';
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

# Create admin user if specified
if [ "${JOOMLA_ADMIN_USER:-}" ] && [ "${JOOMLA_ADMIN_PASSWORD:-}" ]; then
echo "Creating admin user..."
ADMIN_HASH=$(php -r "echo password_hash('${JOOMLA_ADMIN_PASSWORD}', PASSWORD_BCRYPT);")
mysql -h"$JOOMLA_DB_HOST" -u"$JOOMLA_DB_USER" -p"$JOOMLA_DB_PASSWORD" "$JOOMLA_DB_NAME" <<-EOF
INSERT INTO ${JOOMLA_DB_PREFIX:-#__}users (name, username, email, password, block, sendEmail, registerDate, lastvisitDate, activation, params) 
VALUES ('${JOOMLA_ADMIN_USER}', '${JOOMLA_ADMIN_USERNAME:-${JOOMLA_ADMIN_USER}}', '${JOOMLA_ADMIN_EMAIL:-admin@example.com}', '$ADMIN_HASH', 0, 1, NOW(), NOW(), '', '{}');

SET @user_id = LAST_INSERT_ID();
INSERT INTO ${JOOMLA_DB_PREFIX:-#__}user_usergroup_map (user_id, group_id) VALUES (@user_id, 8);
EOF
fi

# Remove installation folder if it exists
if [ -d installation ]; then
echo "Deleting /installation folder..."
rm -rf installation
fi

echo " [OK] Joomla has been installed"
echo ""
echo " This server is now configured to run Joomla!"
echo ""
echo "========================================================================"
fi

exec "$@"