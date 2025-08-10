# PowerShell Script für Provider-Backup
# Führen Sie dieses Script aus, um Ihre Website für den Provider vorzubereiten

Write-Host "🚀 Erstelle Backup für Provider..." -ForegroundColor Green

# Datum für Backup
$date = Get-Date -Format "yyyy-MM-dd_HH-mm"
$backupDir = "backup_$date"

# Erstelle Backup-Ordner
New-Item -ItemType Directory -Path $backupDir -Force

# Kopiere Joomla-Dateien (ohne cache und tmp)
Write-Host "📁 Kopiere Joomla-Dateien..." -ForegroundColor Yellow
robocopy joomla "$backupDir\joomla" /MIR /XD cache tmp logs /XF configuration.php

# Erstelle Provider-Konfiguration Template
Write-Host "⚙️  Erstelle configuration.php Template..." -ForegroundColor Yellow
@"
<?php
// Provider Configuration Template
// Passen Sie diese Werte an Ihren Provider an:

public `$host = 'IHR_MYSQL_HOST';           // z.B. localhost
public `$user = 'IHR_DB_USER';              // Ihr DB Benutzername  
public `$password = 'IHR_DB_PASSWORD';      // Ihr DB Passwort
public `$db = 'IHR_DATABASE_NAME';          // Ihr DB Name
public `$dbprefix = 'joom_';                // Tabellen-Prefix

// Weitere Einstellungen von Ihrer lokalen configuration.php übernehmen!
"@ | Out-File -FilePath "$backupDir\configuration_TEMPLATE_FOR_PROVIDER.php" -Encoding UTF8

Write-Host "✅ Backup erstellt in: $backupDir" -ForegroundColor Green
Write-Host "📤 Uploadinstruktionen:" -ForegroundColor Cyan
Write-Host "   1. Joomla-Ordner komplett zum Provider uploaden" -ForegroundColor White
Write-Host "   2. Datenbank über phpMyAdmin exportieren und beim Provider importieren" -ForegroundColor White
Write-Host "   3. configuration.php für Provider anpassen" -ForegroundColor White
