#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

echo "🗄️  Creating database backup..."

# Load .env file
if [ -f ".env" ]; then
    export $(grep -v '^#' .env | xargs)
else
    echo "❌ .env file not found!"
    exit 1
fi

projectName="${PROJECT_NAME}"
dbPassword="${MYSQL_ROOT_PASSWORD}"
dbName="${MYSQL_DATABASE}"
backupTarget="${DB_BACKUP_TARGET}"

# Prüfen ob alle benötigten Variablen gesetzt sind
if [ -z "$dbName" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_HOST" ] || [ -z "$backupTarget" ] || [ -z "$projectName" ]; then
    echo "Fehler: Nicht alle benötigten Variablen sind in der .env-Datei gesetzt."
    echo "Benötigt: MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD, MYSQL_HOST, DB_BACKUP_TARGET, PROJECT_NAME"
    exit 1
fi

date=$(date +"%Y-%m-%d_%H-%M-%S")
backupFile="${projectName}_${dbName}_backup_${date}.sql"
backupDir="${backupTarget}/${projectName}/${date}"
backupFullPath="${backupTarget}/${projectName}/${date}/${backupFile}"

mkdir -p "${backupDir}"

echo "📋 Backup Details:"
echo "   Project: $projectName"
echo "   Database: $dbName"
echo "   File: $backupFile"
echo "   Backup Path: $backupFullPath"
echo ""

# Backup-Verzeichnis erstellen falls es nicht existiert
mkdir -p "$backupTarget"

containerName="${projectName}-mysql"
echo "🔄 Running database export..."

docker exec "$containerName" mysqldump -u root -p"$dbPassword" "$dbName" > "$backupFullPath"

if [ -f "$backupFullPath" ]; then
    fileSize=$(du -k "$backupFullPath" | cut -f1)
    echo "✅ Database exported: $backupFullPath (${fileSize} KB)"
    echo ""
    echo "📤 NEXT STEPS FOR PROVIDER UPLOAD:"
    echo "1. Transfer this SQL file to your hosting provider"
    echo "2. Open phpMyAdmin on your hosting provider"
    echo "3. Select/create database"
    echo "4. Choose 'Import' and upload the SQL file"
    echo "5. Upload Joomla files from 'joomla/' folder via FTP"
    echo "6. Adjust configuration.php with your provider's database settings"
else
    echo "❌ Export failed!"
    echo "💡 Make sure containers are running: docker compose ps"
fi
# Prüfen ob das Backup erfolgreich war
if [ $? -eq 0 ]; then
    echo "✅ Backup erfolgreich erstellt: $backupFullPath"

    # Dateigröße anzeigen
    FILESIZE=$(du -h "$backupFullPath" | cut -f1)
    echo "📁 Dateigröße: $FILESIZE"
else
    echo "❌ Fehler beim Erstellen des Backups!"
    exit 1
fi

# ############################################ JOOMLA-Verzeichnis ############################################

# 2. Joomla-Verzeichnis sichern
echo " "
echo "🔄 Backup Joomla Directory..."
tar -czf "$backupDir/${projectName}_joomla_files_${date}.tar.gz" \
    -C ./joomla .

echo "✅ Vollständiges Backup erstellt in: $backupDir"