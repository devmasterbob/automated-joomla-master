# Database Export for Provider
# Exports the database for upload to hosting provider

Write-Host "🗄️  Exporting database..." -ForegroundColor Green

# Load .env file
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.+)$") {
            [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2])
        }
    }
}
else {
    Write-Host "❌ .env file not found!" -ForegroundColor Red
    exit 1
}

$projectName = [Environment]::GetEnvironmentVariable("PROJECT_NAME")
$dbPassword = [Environment]::GetEnvironmentVariable("MYSQL_ROOT_PASSWORD")
$dbName = [Environment]::GetEnvironmentVariable("MYSQL_DATABASE")

$date = Get-Date -Format "yyyy-MM-dd_HH-mm"
$exportFile = "${projectName}_database_export_$date.sql"

Write-Host "📋 Export Details:" -ForegroundColor Cyan
Write-Host "   Project: $projectName" -ForegroundColor White
Write-Host "   Database: $dbName" -ForegroundColor White
Write-Host "   File: $exportFile" -ForegroundColor White
Write-Host ""

# Docker Command for MySQL Dump
$containerName = "$projectName-mysql"
Write-Host "🔄 Running database export..." -ForegroundColor Yellow

docker exec $containerName mysqldump -u root -p$dbPassword $dbName > $exportFile

if (Test-Path $exportFile) {
    $fileSize = [math]::Round((Get-Item $exportFile).Length / 1KB, 2)
    Write-Host "✅ Database exported: $exportFile ($fileSize KB)" -ForegroundColor Green
    Write-Host ""
    Write-Host "📤 NEXT STEPS FOR PROVIDER UPLOAD:" -ForegroundColor Cyan
    Write-Host "1. Transfer this SQL file to your hosting provider" -ForegroundColor White
    Write-Host "2. Open phpMyAdmin on your hosting provider" -ForegroundColor White
    Write-Host "3. Select/create database" -ForegroundColor White
    Write-Host "4. Choose 'Import' and upload the SQL file" -ForegroundColor White
    Write-Host "5. Upload Joomla files from 'joomla/' folder via FTP" -ForegroundColor White
    Write-Host "6. Adjust configuration.php with your provider's database settings" -ForegroundColor White
}
else {
    Write-Host "❌ Export failed!" -ForegroundColor Red
    Write-Host "💡 Make sure containers are running: docker-compose ps" -ForegroundColor Yellow
}
