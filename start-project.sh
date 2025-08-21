#!/bin/bash

echo "🚀 Starting Automated Joomla Master Project..."

# Load .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

# Check password length (minimum 12 characters for Joomla)
for var in JOOMLA_ADMIN_PASSWORD JOOMLA_DB_PASSWORD MYSQL_ROOT_PASSWORD; do
    passwordValue="${!var}"
    if [ -n "$passwordValue" ] && [ ${#passwordValue} -lt 12 ]; then
        echo "❌ Password too short in $var! Found: ${#passwordValue} characters"
        echo "💡 Joomla recommends passwords with at least 12 characters"
        echo "   Current: '$passwordValue' (${#passwordValue} chars)"
        echo "   Example: 'admin12345678' (12+ chars)"
        read -p "Do you want to continue anyway? (y/N) " continue
        if [[ ! "$continue" =~ ^[yY]$ ]]; then
            echo "Aborted by user due to short password."
            exit 1
        fi
    fi
done

# Start containers
echo "🔄 Starting containers..."
docker compose up -d --remove-orphans

if [ $? -eq 0 ]; then
    echo "✅ Containers started successfully!"
    echo ""
    echo "📋 Your URLs are now available:"
    echo "   🏠 Project Info:  http://${LANDING_HOST_IP:-localhost}:${PORT_LANDING:-81}"
    echo "   🌍 Joomla CMS:    http://${LANDING_HOST_IP:-localhost}:${PORT_JOOMLA:-80}"
    echo "   🗄️ phpMyAdmin:    http://${LANDING_HOST_IP:-localhost}:${PORT_PHPMYADMIN:-82}"
else
    echo "❌ Container startup failed!"
    exit 1
fi