# Database Export für Provider
# Exportiert die Datenbank für den Upload zum Provider

Write-Host "🗄️  Exportiere Datenbank..." -ForegroundColor Green

# .env Datei laden
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.+)$") {
            [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2])
        }
    }
}
else {
    Write-Host "❌ .env Datei nicht gefunden!" -ForegroundColor Red
    exit 1
}

$projectName = [Environment]::GetEnvironmentVariable("PROJECT_NAME")
$dbUser = [Environment]::GetEnvironmentVariable("MYSQL_USER")
$dbPassword = [Environment]::GetEnvironmentVariable("MYSQL_ROOT_PASSWORD")
$dbName = [Environment]::GetEnvironmentVariable("MYSQL_DATABASE")

$date = Get-Date -Format "yyyy-MM-dd_HH-mm"
$exportFile = "${projectName}_database_export_$date.sql"

Write-Host "📋 Export-Details:" -ForegroundColor Cyan
Write-Host "   Projekt: $projectName" -ForegroundColor White
Write-Host "   Datenbank: $dbName" -ForegroundColor White
Write-Host "   Datei: $exportFile" -ForegroundColor White
Write-Host ""

# Docker Command für MySQL Dump
$containerName = "$projectName-mysql"
Write-Host "🔄 Führe Datenbank-Export aus..." -ForegroundColor Yellow

docker exec $containerName mysqldump -u root -p$dbPassword $dbName > $exportFile

if (Test-Path $exportFile) {
    $fileSize = [math]::Round((Get-Item $exportFile).Length / 1KB, 2)
    Write-Host "✅ Datenbank exportiert: $exportFile ($fileSize KB)" -ForegroundColor Green
    Write-Host ""
    Write-Host "📤 NÄCHSTE SCHRITTE FÜR PROVIDER-UPLOAD:" -ForegroundColor Cyan
    Write-Host "1. Diese SQL-Datei zum Provider übertragen" -ForegroundColor White
    Write-Host "2. Beim Provider phpMyAdmin öffnen" -ForegroundColor White
    Write-Host "3. Datenbank auswählen/erstellen" -ForegroundColor White
    Write-Host "4. 'Importieren' wählen und SQL-Datei hochladen" -ForegroundColor White
    Write-Host "5. Joomla-Dateien aus 'joomla/' Ordner per FTP hochladen" -ForegroundColor White
    Write-Host "6. configuration.php beim Provider anpassen" -ForegroundColor White
}
else {
    Write-Host "❌ Export fehlgeschlagen!" -ForegroundColor Red
    Write-Host "💡 Stelle sicher, dass die Container laufen: docker-compose ps" -ForegroundColor Yellow
}
