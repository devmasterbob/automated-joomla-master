#!/bin/bash

echo "🚀 Starting Automated Joomla Master Project..."

# Load .env file
if [ ! -f ".env" ]; then
    echo "❌ .env file not found!"
    echo "💡 Please run the preparation script first:"
    echo "   ./prepare.sh"
    echo ""
    echo "   This will create and customize your .env file."
    exit 1
fi

# Load environment variables
export $(grep -v '^#' .env | xargs)

projectName="${PROJECT_NAME}"
portLanding="${PORT_LANDING}"
portJoomla="${PORT_JOOMLA}"
portPhpMyAdmin="${PORT_PHPMYADMIN}"

if [ -z "$projectName" ] || [ "$projectName" == "your-new-project-name" ]; then
    echo "❌ PROJECT_NAME not set or still default value!"
    echo "💡 Please edit .env file and set PROJECT_NAME to your project name"
    echo "   Example: PROJECT_NAME=my-joomla-site"
    exit 1
fi

problematicChars='$`"'\''\§'
passwordVars=(MYSQL_PASSWORD MYSQL_ROOT_PASSWORD JOOMLA_ADMIN_PASSWORD JOOMLA_DB_PASSWORD)

for passwordVar in "${passwordVars[@]}"; do
    passwordValue="${!passwordVar}"
    if [ -n "$passwordValue" ]; then
        if [ ${#passwordValue} -lt 12 ]; then
            echo "❌ Password too short in $passwordVar! Found: ${#passwordValue} characters"
            echo "💡 Joomla recommends passwords with at least 12 characters"
            echo "   Current: '$passwordValue' (${#passwordValue} chars)"
            echo "   Example: 'admin12345678' (12+ chars)"
            read -p "Do you want to continue anyway? (y/N) " continue
            if [[ ! "$continue" =~ ^[yY]$ ]]; then
                echo "Aborted by user due to short password."
                exit 1
            fi
        fi
        for char in $(echo $problematicChars | fold -w1); do
            if [[ "$passwordValue" == *"$char"* ]]; then
                echo "❌ Password contains problematic character '$char' in $passwordVar!"
                echo "💡 Please use only: A-Z, a-z, 0-9, -, _, ., +, *, #, @, %, &, (, ), =, ?, !"
                echo "   Avoid these characters: § dollar-sign backtick quotes backslash"
                exit 1
            fi
        done
    fi
done

volumeName="${projectName}_db_data"
volumeExists=$(docker volume ls -q -f name="$volumeName")

if [ -n "$volumeExists" ]; then
    echo "🔍 Existing database volume detected"
    echo "   Volume: $volumeName"
    echo ""
    echo "🔄 Starting containers to check database..."
    docker compose up -d --quiet-pull
    echo "⏳ Waiting for database to start..."
    sleep 10
    # Check for Joomla tables
    hasJoomlaData=false
    dbCheck=$(docker compose exec -T db mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "USE $MYSQL_DATABASE; SHOW TABLES LIKE 'joom_%';" 2>/dev/null)
    if [ -n "$dbCheck" ]; then
        hasJoomlaData=true
    fi
    if [ "$hasJoomlaData" = true ]; then
        echo "✅ Existing Joomla data found - protecting your content!"
        echo "🔐 Updating database passwords to match .env file..."
        docker compose exec -T db mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "ALTER USER '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASSWORD'; ALTER USER 'root'@'%' IDENTIFIED BY '$MYSQL_ROOT_PASSWORD'; FLUSH PRIVILEGES;" 2>/dev/null
        echo "✅ Database passwords synchronized with .env file"
        echo "💾 Your Joomla content (articles, menus, settings) is preserved!"
        echo ""
    fi
else
    echo "🆕 Fresh installation detected - setting up new project..."
fi

# Start containers (if not already started for database check)
if [ -z "$volumeExists" ]; then
    echo "🔄 Starting Docker containers..."
    echo "   Project Name: $projectName"
    docker compose up -d
else
    echo "🔄 Ensuring all containers are running..."
    docker compose up -d --quiet-pull
fi

if [ $? -eq 0 ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "🎉                 CONTAINERS STARTED SUCCESSFULLY!"
    echo "═══════════════════════════════════════════════════════════════"
    echo ""

    # Check if Joomla is already installed by looking for configuration.php
    joomlaPath="./joomla"
    configExists=false
    isConfigured=false
    if [ -f "$joomlaPath/configuration.php" ]; then
        configExists=true
        configSize=$(stat -c%s "$joomlaPath/configuration.php")
        if [ "$configSize" -gt 1000 ]; then
            isConfigured=true
        fi
    fi

    if [ "$isConfigured" = false ]; then
        echo "🔄 Monitoring Joomla installation..."
        echo "   (This will take 2-3 minutes - please wait)"
        echo ""
        maxAttempts=30
        attempt=0
        joomlaContainerName="${projectName}-joomla"
        while [ $attempt -lt $maxAttempts ]; do
            attempt=$((attempt+1))
            sleep 6
            logs=$(docker logs "$joomlaContainerName" --tail 5 2>/dev/null)
            if echo "$logs" | grep -q "Joomla installation completed"; then
                echo "   ✅ Joomla installation completed!"
                break
            fi
            echo "   ...waiting ($((attempt*6))s)"
        done
        echo ""
        echo ""
    else
        echo "✅ Existing Joomla installation detected - starting quickly..."
        echo ""
        sleep 2
    fi

    echo "📋 Your URLs are now available:"
    echo "   🏠 Project Info:  http://localhost:$portLanding"
    echo "   🌍 Joomla CMS:    http://localhost:$portJoomla"
    echo "   🗄️ phpMyAdmin:    http://localhost:$portPhpMyAdmin"
    echo ""

    # Hinweis für Error 500
    echo "⚠️  IMPORTANT: If you get 'Error 500' on first visit:"
    echo "   • Wait 30 seconds more for full installation"
    echo "   • Clear browser cache (Ctrl+F5)"
    echo "   • Or run: docker compose down -v --remove-orphans && ./start-project.sh"
    echo ""
    echo "🔐 Default Login Credentials:"
    echo "   Joomla Admin:  admin / (see .env file)"
    echo "   phpMyAdmin:    root / (see .env file)"
    echo ""
    echo "💡 Pro Tip: Start with http://localhost:$portLanding for project overview!"
    echo ""
    echo "═══════════════════════════════════════════════════════════════"
    echo "   Project: $projectName | Status: Ready for Development! 🚀"
    echo "═══════════════════════════════════════════════════════════════"
else
    echo ""
    echo "❌ Container startup failed!"
    echo "💡 Please check: docker compose logs"
fi