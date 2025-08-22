#!/bin/bash

# Pfad zur .env-Datei (anpassen falls nötig)
ENV_FILE=".env"

# Prüfen ob .env-Datei existiert
if [ ! -f "$ENV_FILE" ]; then
    echo "Fehler: .env-Datei nicht gefunden: $ENV_FILE"
    exit 1
fi

# .env-Datei laden und Variablen exportieren
set -a  # automatisches Exportieren aller Variablen
source "$ENV_FILE"
set +a  # automatisches Exportieren deaktivieren

# Prüfen ob alle benötigten Variablen gesetzt sind
if [ -z "$MYSQL_DATABASE" ] || [ -z "$MYSQL_USER" ] || [ -z "$MYSQL_PASSWORD" ] || [ -z "$MYSQL_HOST" ] || [ -z "$DB_BACKUP_TARGET" ] || [ -z "$PROJECT_NAME" ]; then
    echo "Fehler: Nicht alle benötigten Variablen sind in der .env-Datei gesetzt."
    echo "Benötigt: MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD, MYSQL_HOST, DB_BACKUP_TARGET, PROJECT_NAME"
    exit 1
fi

# Zeitstempel erstellen (Format: YYYY-MM-DD_HH-MM-SS)
TIMESTAMP=$(date +"%Y-%m-%d_%H-%M-%S")

# Backup-Dateiname mit Zeitstempel
BACKUP_FILENAME="${PROJECT_NAME}_${MYSQL_DATABASE}_backup_${TIMESTAMP}.sql"
BACKUP_FULL_PATH="${DB_BACKUP_TARGET}/${BACKUP_FILENAME}"

# Backup-Verzeichnis erstellen falls es nicht existiert
mkdir -p "$DB_BACKUP_TARGET"

# MySQL-Dump erstellen
echo "Erstelle MySQL-Backup für Datenbank: $MYSQL_DATABASE"
echo "Ziel: $BACKUP_FULL_PATH"

mysqldump \
    --host="$MYSQL_HOST" \
    --port="$MYSQL_PORT" \
    --user="$MYSQL_USER" \
    --password="$MYSQL_PASSWORD" \
    --single-transaction \
    --routines \
    --triggers \
    "$MYSQL_DATABASE" > "$BACKUP_FULL_PATH"

# Prüfen ob das Backup erfolgreich war
if [ $? -eq 0 ]; then
    echo "✅ Backup erfolgreich erstellt: $BACKUP_FULL_PATH"
    
    # Dateigröße anzeigen
    FILESIZE=$(du -h "$BACKUP_FULL_PATH" | cut -f1)
    echo "📁 Dateigröße: $FILESIZE"
else
    echo "❌ Fehler beim Erstellen des Backups!"
    exit 1
fi
