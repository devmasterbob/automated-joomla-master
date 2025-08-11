# Start Automated Joomla Master Project
# Starts all containers and displays helpful information

Write-Host "🚀 Starting Automated Joomla Master..." -ForegroundColor Green
Write-Host ""

# Load .env file to get project name and ports
if (Test-Path ".env") {
    $envVariables = @{}
    
    # First pass: Read all variables
    Get-Content ".env" | ForEach-Object {
        if ($_ -match "^([^#][^=]+)=(.+)$") {
            $key = $Matches[1].Trim()
            $value = $Matches[2].Trim()
            # Remove quotes if present
            if ($value -match '^"(.*)"$' -or $value -match "^'(.*)'$") {
                $value = $Matches[1]
            }
            $envVariables[$key] = $value
        }
    }
    
    # Second pass: Resolve variable substitutions
    $resolved = $false
    do {
        $resolved = $true
        $keysToUpdate = @()
        
        # Find keys that need updating (don't modify during enumeration)
        foreach ($key in $envVariables.Keys) {
            $value = $envVariables[$key]
            # Check for ${VARIABLE} pattern
            if ($value -match '\$\{([^}]+)\}') {
                $varName = $Matches[1]
                if ($envVariables.ContainsKey($varName)) {
                    $keysToUpdate += @{Key = $key; OldValue = $value; VarName = $varName }
                    $resolved = $false
                }
            }
        }
        
        # Now update the keys
        foreach ($update in $keysToUpdate) {
            $newValue = $update.OldValue -replace '\$\{' + [regex]::Escape($update.VarName) + '\}', $envVariables[$update.VarName]
            $envVariables[$update.Key] = $newValue
        }
    } while (-not $resolved)
    
    # Set environment variables
    foreach ($key in $envVariables.Keys) {
        [Environment]::SetEnvironmentVariable($key, $envVariables[$key])
    }
}
else {
    Write-Host "❌ .env file not found! Please copy .env-example to .env first." -ForegroundColor Red
    Write-Host "💡 Run: cp .env-example .env" -ForegroundColor Yellow
    exit 1
}

$projectName = $envVariables["PROJECT_NAME"]
$portLanding = $envVariables["PORT_LANDING"]
$portJoomla = $envVariables["PORT_JOOMLA"] 
$portPhpMyAdmin = $envVariables["PORT_PHPMYADMIN"]

# Validate project name
if (-not $projectName -or $projectName -eq "" -or $projectName -eq "your-new-project-name") {
    Write-Host "❌ PROJECT_NAME not set or still default value!" -ForegroundColor Red
    Write-Host "💡 Please edit .env file and set PROJECT_NAME to your project name" -ForegroundColor Yellow
    Write-Host "   Example: PROJECT_NAME=my-joomla-site" -ForegroundColor Cyan
    exit 1
}

# Start containers
Write-Host "🔄 Starting Docker containers..." -ForegroundColor Cyan
Write-Host "   Project Name: $projectName" -ForegroundColor Gray
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
