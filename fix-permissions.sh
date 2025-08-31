#!/bin/bash
sudo chown -R www-data:www-data ./joomla
sudo chmod -R 755 ./joomla
sudo chmod -R 777 ./joomla/tmp ./joomla/logs ./joomla/cache
echo "Berechtigungen wurden korrigiert"
