# Pfad zur .env-Datei (anpassen falls nötig)
$EnvFile = ".env"

# Prüfen ob .env-Datei existiert
if (-not (Test-Path $EnvFile)) {
    Write-Host "Fehler: .env-Datei nicht gefunden: $EnvFile" -ForegroundColor Red
    exit 1
}

# Funktion zum Laden der .env-Datei
function Get-EnvFile {
    param($Path)
    
    Get-Content $Path | ForEach-Object {
        if ($_ -match "^\s*([^#][^=]*)\s*=\s*(.*)\s*$") {
            $name = $matches[1].Trim()
            $value = $matches[1].Trim()
            
            # Einfache Variable-Substitution für ${VARIABLE} Format
            while ($value -match '\$\{([^}]+)\}') {
                $varName = $matches[1]
                $varValue = [Environment]::GetEnvironmentVariable($varName)
                if ($varValue) {
                    $value = $value -replace "\`$\{$varName\}", $varValue
                }
                else {
                    break
                }
            }
            
            [Environment]::SetEnvironmentVariable($name, $value)
        }
    }
}

# .env-Datei laden
Get-EnvFile -Path $EnvFile

# Variablen aus Umgebung lesen
$MYSQL_DATABASE = [Environment]::GetEnvironmentVariable("MYSQL_DATABASE")
$MYSQL_USER = [Environment]::GetEnvironmentVariable("MYSQL_USER")
$MYSQL_PASSWORD = [Environment]::GetEnvironmentVariable("MYSQL_PASSWORD")
$MYSQL_HOST = [Environment]::GetEnvironmentVariable("MYSQL_HOST")
$MYSQL_PORT = [Environment]::GetEnvironmentVariable("MYSQL_PORT")
$DB_BACKUP_TARGET = [Environment]::GetEnvironmentVariable("DB_BACKUP_TARGET")
$PROJECT_NAME = [Environment]::GetEnvironmentVariable("PROJECT_NAME")

# Prüfen ob alle benötigten Variablen gesetzt sind
if (-not $MYSQL_DATABASE -or -not $MYSQL_USER -or -not $MYSQL_PASSWORD -or -not $MYSQL_HOST -or -not $DB_BACKUP_TARGET -or -not $PROJECT_NAME) {
    Write-Host "Fehler: Nicht alle benötigten Variablen sind in der .env-Datei gesetzt." -ForegroundColor Red
    Write-Host "Benötigt: MYSQL_DATABASE, MYSQL_USER, MYSQL_PASSWORD, MYSQL_HOST, DB_BACKUP_TARGET, PROJECT_NAME" -ForegroundColor Red
    exit 1
}

# Zeitstempel erstellen (Format: YYYY-MM-DD_HH-MM-SS)
$TIMESTAMP = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"

# Backup-Dateiname mit Zeitstempel
$BACKUP_FILENAME = "${PROJECT_NAME}_${MYSQL_DATABASE}_backup_${TIMESTAMP}.sql"
$BACKUP_FULL_PATH = Join-Path $DB_BACKUP_TARGET $BACKUP_FILENAME

# Backup-Verzeichnis erstellen falls es nicht existiert
if (-not (Test-Path $DB_BACKUP_TARGET)) {
    New-Item -ItemType Directory -Path $DB_BACKUP_TARGET -Force | Out-Null
}

# MySQL-Dump erstellen
Write-Host "Erstelle MySQL-Backup für Datenbank: $MYSQL_DATABASE" -ForegroundColor Green
Write-Host "Ziel: $BACKUP_FULL_PATH" -ForegroundColor Green

# mysqldump-Befehl ausführen
$mysqldumpArgs = @(
    "--host=$MYSQL_HOST",
    "--port=$MYSQL_PORT",
    "--user=$MYSQL_USER",
    "--password=$MYSQL_PASSWORD",
    "--single-transaction",
    "--routines",
    "--triggers",
    $MYSQL_DATABASE
)

try {
    # mysqldump ausführen und Ausgabe in Datei umleiten
    & mysqldump @mysqldumpArgs | Out-File -FilePath $BACKUP_FULL_PATH -Encoding UTF8
    
    # Prüfen ob die Datei erstellt wurde und Inhalt hat
    if ((Test-Path $BACKUP_FULL_PATH) -and (Get-Item $BACKUP_FULL_PATH).Length -gt 0) {
        Write-Host "✅ Backup erfolgreich erstellt: $BACKUP_FULL_PATH" -ForegroundColor Green
        
        # Dateigröße anzeigen
        $fileSize = Get-Item $BACKUP_FULL_PATH | ForEach-Object { 
            if ($_.Length -gt 1MB) {
                "{0:N2} MB" -f ($_.Length / 1MB)
            }
            elseif ($_.Length -gt 1KB) {
                "{0:N2} KB" -f ($_.Length / 1KB)
            }
            else {
                "{0} Bytes" -f $_.Length
            }
        }
        Write-Host "📁 Dateigröße: $fileSize" -ForegroundColor Green
    }
    else {
        Write-Host "❌ Fehler beim Erstellen des Backups!" -ForegroundColor Red
        exit 1
    }
}
catch {
    Write-Host "❌ Fehler beim Ausführen von mysqldump: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}
