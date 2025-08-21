#!/bin/bash

echo "🗄️  Exporting database..."

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

date=$(date +"%Y-%m-%d_%H-%M")
exportFile="${projectName}_database_export_${date}.sql"

echo "📋 Export Details:"
echo "   Project: $projectName"
echo "   Database: $dbName"
echo "   File: $exportFile"
echo ""

containerName="${projectName}-mysql"
echo "🔄 Running database export..."

docker exec "$containerName" mysqldump -u root -p"$dbPassword" "$dbName" > "$exportFile"

if [ -f "$exportFile" ]; then
    fileSize=$(du -k "$exportFile" | cut -f1)
    echo "✅ Database exported: $exportFile (${fileSize} KB)"
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