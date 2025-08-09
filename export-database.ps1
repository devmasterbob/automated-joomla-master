# Database Export für Provider
# Exportiert die Datenbank für den Upload zum Provider

Write-Host "🗄️  Exportiere Datenbank..." -ForegroundColor Green

$date = Get-Date -Format "yyyy-MM-dd_HH-mm"
$exportFile = "database_export_$date.sql"

# Docker Command für MySQL Dump
docker exec web-joomla-master-2508-09-db-1 mysqldump -u root -prootpass joomla_db > $exportFile

if (Test-Path $exportFile) {
    Write-Host "✅ Datenbank exportiert: $exportFile" -ForegroundColor Green
    Write-Host "📤 Diese Datei beim Provider in phpMyAdmin importieren!" -ForegroundColor Cyan
} else {
    Write-Host "❌ Export fehlgeschlagen!" -ForegroundColor Red
}
