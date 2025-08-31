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

# Load environment variables with variable expansion
set -a
source .env
set +a

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


# --- Erweiterte Konfigurations-Synchronisation (Site Name, Admin Email, Port) ---
joomlaConfig="./joomla/configuration.php"
syncNeeded=false

if [ -f "$joomlaConfig" ]; then
    # Site Name
    currentSiteName=$(grep -E "public \$sitename\s*=" "$joomlaConfig" | sed "s/.*='\(.*\)';/\1/")
    if [ "$currentSiteName" != "$JOOMLA_SITE_NAME" ]; then
        sed -i "s/public \$sitename = '.*';/public \$sitename = '$JOOMLA_SITE_NAME';/" "$joomlaConfig"
        echo "🔄 Synchronized Site Name in configuration.php: $JOOMLA_SITE_NAME"
        syncNeeded=true
    fi
    # Admin Email
    currentAdminEmail=$(grep -E "public \$mailfrom\s*=" "$joomlaConfig" | sed "s/.*='\(.*\)';/\1/")
    if [ "$currentAdminEmail" != "$JOOMLA_ADMIN_EMAIL" ]; then
        sed -i "s/public \$mailfrom = '.*';/public \$mailfrom = '$JOOMLA_ADMIN_EMAIL';/" "$joomlaConfig"
        echo "🔄 Synchronized Admin Email in configuration.php: $JOOMLA_ADMIN_EMAIL"
        syncNeeded=true
    fi
    # Port (optional, falls in config vorhanden)
    if grep -q "public \$live_site" "$joomlaConfig"; then
        sed -i "s/public \$live_site = '.*';/public \$live_site = 'http:\/\/localhost:$PORT_JOOMLA';/" "$joomlaConfig"
        echo "🔄 Synchronized live_site URL in configuration.php: http://localhost:$PORT_JOOMLA"
        syncNeeded=true
    fi
fi

if [ "$syncNeeded" = true ]; then
    echo "✅ configuration.php updated with latest settings from .env"
fi

# Optional: Synchronisiere Site Name und Admin Email auch in der Datenbank (wenn Joomla läuft)
joomlaContainerName="${projectName}-joomla"
if docker compose ps | grep -q "$joomlaContainerName"; then
    # Site Name
    docker compose exec -T db mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
        -e "UPDATE \`joom_config\` SET \`value\` = '$JOOMLA_SITE_NAME' WHERE \`name\` = 'sitename';" 2>/dev/null
    # Admin Email
    docker compose exec -T db mysql -u "$MYSQL_USER" -p"$MYSQL_PASSWORD" "$MYSQL_DATABASE" \
        -e "UPDATE \`joom_config\` SET \`value\` = '$JOOMLA_ADMIN_EMAIL' WHERE \`name\` = 'mailfrom';" 2>/dev/null
    echo "✅ Joomla database settings synchronized (Site Name, Admin Email)"
fi

volumeName="${projectName}_db_data"
volumeExists=$(docker volume ls -q -f name="$volumeName")

# --- Recovery- und Fallback-Logik für Datenbank-Variablen ---
dbVars=("MYSQL_ROOT_PASSWORD" "MYSQL_PASSWORD" "MYSQL_USER" "MYSQL_DATABASE")
dbVarChanged=false
dbVarWarnings=()

if [ -n "$volumeExists" ]; then
    echo "🔍 Existing database volume detected"
    echo "   Volume: $volumeName"
    echo ""
    echo "🔄 Starting containers to check database..."
    docker compose up -d --quiet-pull
    echo "⏳ Waiting for database to start..."
    sleep 10

    # Prüfe, ob DB-Variablen geändert wurden
    for dbVar in "${dbVars[@]}"; do
        envValue="${!dbVar}"
        # Teste Verbindung mit aktuellen Variablen
        if [ "$dbVar" == "MYSQL_ROOT_PASSWORD" ]; then
            docker compose exec -T db mysql -u root -p"$envValue" -e "SELECT 1;" 2>/dev/null
            if [ $? -ne 0 ]; then
                dbVarChanged=true
                dbVarWarnings+=("$dbVar (changed after initial installation)")
            fi
        elif [ "$dbVar" == "MYSQL_USER" ]; then
            userCheck=$(docker compose exec -T db mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SELECT User FROM mysql.user WHERE User='$envValue';" 2>/dev/null | tail -n +2)
            if [ "$userCheck" != "$envValue" ]; then
                dbVarChanged=true
                dbVarWarnings+=("$dbVar (changed after initial installation)")
            fi
        elif [ "$dbVar" == "MYSQL_DATABASE" ]; then
            dbCheck=$(docker compose exec -T db mysql -u root -p"$MYSQL_ROOT_PASSWORD" -e "SHOW DATABASES LIKE '$envValue';" 2>/dev/null | tail -n +2)
            if [ "$dbCheck" != "$envValue" ]; then
                dbVarChanged=true
                dbVarWarnings+=("$dbVar (changed after initial installation)")
            fi
        elif [ "$dbVar" == "MYSQL_PASSWORD" ]; then
            docker compose exec -T db mysql -u "$MYSQL_USER" -p"$envValue" -e "SELECT 1;" 2>/dev/null
            if [ $? -ne 0 ]; then
                dbVarChanged=true
                dbVarWarnings+=("$dbVar (changed after initial installation)")
            fi
        fi
    done

    if [ "$dbVarChanged" = true ]; then
        echo "❌ Database variables have been changed after initial installation!"
        echo "   These changes are not allowed and will be ignored."
        echo "   Affected variables: ${dbVarWarnings[*]}"
        echo "   Tip: For DB changes, please perform a fresh installation!"
        echo "   The application will continue to use the original database credentials."
        echo "   Only Joomla settings and ports will be synchronized."
    fi

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

    # --- Auto-Cleanup .git and .github ---
    if [ -d ".git" ]; then
        echo "🧹 Removing .git directory for a clean project..."
        rm -rf .git
        echo "✅ .git directory removed."
    fi
    if [ -d ".github" ]; then
        echo "🧹 Removing .github directory for a clean project..."
        rm -rf .github
        echo "✅ .github directory removed."
    fi

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

        # ■■■ HIER DEN NEUEN CODE EINFÜGEN ■■■
    # 🔧 PHP-Konfiguration und Berechtigungen
    echo "🔧 Konfiguriere PHP-Einstellungen und Berechtigungen..."

    # PHP temporäre Ordner-Einstellungen hinzufügen (falls nicht vorhanden)
    phpIniFile="./php.ini"
    customIniFile="./custom.ini"

    if [ -f "$phpIniFile" ]; then
        if ! grep -q "sys_temp_dir" "$phpIniFile"; then
            echo "sys_temp_dir = \"/tmp\"" >> "$phpIniFile"
            echo "upload_tmp_dir = \"/tmp\"" >> "$phpIniFile"
            echo "✅ Temporäre Ordner-Einstellungen zu php.ini hinzugefügt"
        fi
    else
        # Erstelle php.ini falls nicht vorhanden
        cat > "$phpIniFile" << EOF
        display_errors = Off
        upload_max_filesize = 256M
        post_max_size = 256M
        memory_limit = 256M
        max_execution_time = 300
        max_input_vars = 3000
        date.timezone = "UTC"
        sys_temp_dir = "/tmp"
        upload_tmp_dir = "/tmp"
EOF
        echo "✅ php.ini erstellt mit optimalen Einstellungen"
    fi

    # Custom.ini erstellen/aktualisieren für bessere Kompatibilität
    cat > "$customIniFile" << EOF
    ; Joomla-optimierte PHP-Einstellungen
    display_errors = Off
    upload_max_filesize = 256M
    post_max_size = 256M
    memory_limit = 256M
    max_execution_time = 300
    max_input_vars = 3000
    date.timezone = "UTC"
    sys_temp_dir = "/tmp"
    upload_tmp_dir = "/tmp"
EOF

    echo "✅ custom.ini erstellt/aktualisiert"

    # Docker-Compose für custom.ini erweitern (falls noch nicht vorhanden)
    dockerComposeFile="./docker-compose.yaml"
    if ! grep -q "custom.ini" "$dockerComposeFile"; then
        # Backup erstellen
        cp "$dockerComposeFile" "$dockerComposeFile.backup"
        
        # Custom.ini Mount hinzufügen
        sed -i '/- \.\/php\.ini:\/usr\/local\/etc\/php\/php\.ini/a\    - ./custom.ini:/usr/local/etc/php/conf.d/zzz-custom.ini:ro' "$dockerComposeFile"
        echo "✅ custom.ini Mount zu docker-compose.yaml hinzugefügt"
        
        # Container neu starten für neue Konfiguration
        echo "🔄 Starte Container neu für PHP-Konfiguration..."
        docker compose restart joomla
    fi

    # Warten bis Container wieder läuft
    sleep 5

    # Joomla-Ordnerstruktur und Berechtigungen konfigurieren
    joomlaContainerName="${projectName}-joomla"
    echo "🔧 Konfiguriere Joomla-Ordner und Berechtigungen..."

    # Temporäre Ordner im Container erstellen
    docker exec -u root "$joomlaContainerName" mkdir -p /var/www/html/tmp /var/www/html/logs /var/www/html/cache 2>/dev/null
    docker exec -u root "$joomlaContainerName" chmod 777 /var/www/html/tmp /var/www/html/logs /var/www/html/cache 2>/dev/null

    # Host-Berechtigungen setzen (falls die Ordner auf dem Host existieren)
    if [ -d "./joomla/tmp" ]; then
        sudo chown -R www-data:www-data ./joomla/tmp ./joomla/logs ./joomla/cache 2>/dev/null || true
        sudo chmod -R 777 ./joomla/tmp ./joomla/logs ./joomla/cache 2>/dev/null || true
    fi

    # Allgemeine Joomla-Berechtigungen setzen
    sudo chown -R $USER:$USER ./joomla 2>/dev/null || true
    sudo chown -R www-data:www-data ./joomla 2>/dev/null || true
    sudo chmod -R 755 ./joomla 2>/dev/null || true

    echo "✅ Berechtigungen konfiguriert"

    # PHP-Konfiguration überprüfen
    echo "🔍 Überprüfe PHP-Konfiguration..."
    uploadMax=$(docker exec "$joomlaContainerName" php -i | grep upload_max_filesize | head -1 | cut -d' ' -f3)
    postMax=$(docker exec "$joomlaContainerName" php -i | grep post_max_size | head -1 | cut -d' ' -f3)

    if [[ "$uploadMax" == "256M" ]] && [[ "$postMax" == "256M" ]]; then
        echo "✅ PHP-Konfiguration erfolgreich: Upload ${uploadMax}, POST ${postMax}"
    else
        echo "⚠️  PHP-Konfiguration: Upload ${uploadMax}, POST ${postMax}"
        echo "   Falls Werte nicht 256M sind, bitte Container neu starten"
    fi

    echo ""
    # ■■■ ENDE DES NEUEN CODES ■■■


  

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