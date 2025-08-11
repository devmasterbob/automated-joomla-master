# Start Automated Joomla Master Project
# Starts all containers and displays helpful information

Write-Host "🚀 Starting Automated Joomla Master..." -ForegroundColor Green
Write-Host ""

# Load .env file to get project name and ports
if (Test-Path ".env") {
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.+)$") {
            [Environment]::SetEnvironmentVariable($Matches[1], $Matches[2])
        }
    }
}
else {
    Write-Host "❌ .env file not found! Please copy .env-example to .env first." -ForegroundColor Red
    Write-Host "💡 Run: cp .env-example .env" -ForegroundColor Yellow
    exit 1
}

$projectName = [Environment]::GetEnvironmentVariable("PROJECT_NAME")
$portLanding = [Environment]::GetEnvironmentVariable("PORT_LANDING")
$portJoomla = [Environment]::GetEnvironmentVariable("PORT_JOOMLA")
$portPhpMyAdmin = [Environment]::GetEnvironmentVariable("PORT_PHPMYADMIN")

# Start containers
Write-Host "🔄 Starting Docker containers..." -ForegroundColor Cyan
docker-compose up -d

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "🎉                 CONTAINERS STARTED SUCCESSFULLY!" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host ""
    Write-Host "⏰ IMPORTANT: Please wait 2-3 minutes for full initialization!" -ForegroundColor Yellow -BackgroundColor DarkBlue
    Write-Host ""
    Write-Host "📋 Your URLs will be available at:" -ForegroundColor White
    Write-Host "   🏠 Project Info:  http://localhost:$portLanding" -ForegroundColor Cyan
    Write-Host "   🌍 Joomla CMS:    http://localhost:$portJoomla" -ForegroundColor Cyan  
    Write-Host "   🗄️ phpMyAdmin:    http://localhost:$portPhpMyAdmin" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔐 Default Login Credentials:" -ForegroundColor White
    Write-Host "   Joomla Admin:  joomla / joomla@secured" -ForegroundColor Green
    Write-Host "   phpMyAdmin:    root / rootpass" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 Pro Tip: Start with http://localhost:$portLanding for project overview!" -ForegroundColor Magenta
    Write-Host ""
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
    Write-Host "   Project: $projectName | Status: Ready for Development! 🚀" -ForegroundColor Green
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Green
}
else {
    Write-Host ""
    Write-Host "❌ Container startup failed!" -ForegroundColor Red
    Write-Host "💡 Please check: docker-compose logs" -ForegroundColor Yellow
}
