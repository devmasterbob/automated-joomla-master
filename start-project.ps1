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
    $maxIterations = 10  # Prevent infinite loops
    $iteration = 0
    
    do {
        $resolved = $true
        $keysToUpdate = @()
        $iteration++
        
        # Find keys that need updating (don't modify during enumeration)
        foreach ($key in $envVariables.Keys) {
            $value = $envVariables[$key]
            # Check for ${VARIABLE} pattern
            if ($value -match '\$\{([^}]+)\}') {
                $varName = $Matches[1]
                if ($envVariables.ContainsKey($varName)) {
                    # Check for self-reference (circular reference)
                    if ($key -eq $varName) {
                        # Skip self-references to avoid infinite loops
                        continue
                    }
                    else {
                        $keysToUpdate += @{Key = $key; OldValue = $value; VarName = $varName }
                        $resolved = $false
                    }
                }
            }
        }
        
        # Now update the keys
        foreach ($update in $keysToUpdate) {
            $oldValue = $update.OldValue
            $targetVar = $update.VarName
            $replacementValue = $envVariables[$targetVar]
            
            # Use simple string replacement instead of regex
            $newValue = $oldValue.Replace("`${$targetVar}", $replacementValue)
            $envVariables[$update.Key] = $newValue
        }
        
        if ($iteration -ge $maxIterations) {
            break
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

# Validate passwords don't contain problematic characters
$problematicChars = @('$', '`', '"', "'", '\', '§')
$passwordVars = @('MYSQL_PASSWORD', 'MYSQL_ROOT_PASSWORD', 'JOOMLA_ADMIN_PASSWORD', 'JOOMLA_DB_PASSWORD')

foreach ($passwordVar in $passwordVars) {
    $passwordValue = $envVariables[$passwordVar]
    if ($passwordValue) {
        foreach ($char in $problematicChars) {
            if ($passwordValue.Contains($char)) {
                Write-Host "❌ Password contains problematic character '$char' in $passwordVar!" -ForegroundColor Red
                Write-Host "💡 Please use only: A-Z, a-z, 0-9, -, _, ., +, *, #, @, %, &, (, ), =, ?, !" -ForegroundColor Yellow
                Write-Host "   Avoid these characters: § dollar-sign backtick quotes backslash" -ForegroundColor Red
                exit 1
            }
        }
    }
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
    
    # Check if Joomla is already installed by looking for configuration.php
    $joomlaPath = "./joomla"
    $configExists = Test-Path "$joomlaPath/configuration.php"
    $isConfigured = $false
    
    if ($configExists) {
        $configContent = Get-Content "$joomlaPath/configuration.php" -Raw -ErrorAction SilentlyContinue
        if ($configContent -and ($configContent.Length -gt 1000)) {
            $isConfigured = $true
        }
    }
    
    if (-not $isConfigured) {
        # Fresh installation - show monitoring
        Write-Host "🔄 Monitoring Joomla installation..." -ForegroundColor Yellow
        Write-Host "   (This will take 2-3 minutes - please wait)" -ForegroundColor Gray
        Write-Host ""
        
        # Monitor Joomla installation
        $maxAttempts = 30
        $attempt = 0
        $joomlaContainerName = "$projectName-joomla"
        
        do {
            $attempt++
            Start-Sleep -Seconds 6
            
            # Get container logs
            $logs = docker logs $joomlaContainerName --tail 5 2>$null
            if ($logs) {
                $latestLog = $logs | Select-Object -Last 1
                if ($latestLog -match "copying now") {
                    Write-Host "   📥 Copying Joomla files..." -ForegroundColor Cyan
                }
                elseif ($latestLog -match "database") {
                    Write-Host "   🗄️ Setting up database..." -ForegroundColor Cyan
                }
                elseif ($latestLog -match "Joomla installation completed") {
                    Write-Host "   ✅ Joomla installation completed!" -ForegroundColor Green
                    break
                }
                elseif ($latestLog -match "configured -- resuming normal") {
                    Write-Host "   🚀 Apache server ready!" -ForegroundColor Green
                    Write-Host "   ⏳ Finishing installation..." -ForegroundColor Cyan
                }
            }
            
            # Show progress dots
            Write-Host "   $("." * ($attempt % 4))   " -ForegroundColor Gray -NoNewline
            Write-Host "`r" -NoNewline
            
        } while ($attempt -lt $maxAttempts)
        
        Write-Host ""
        Write-Host ""
    }
    else {
        # Existing installation - quick start
        Write-Host "✅ Existing Joomla installation detected - starting quickly..." -ForegroundColor Green
        Write-Host ""
        Start-Sleep -Seconds 2
    }
    
    Write-Host "📋 Your URLs are now available:" -ForegroundColor White
    Write-Host "   🏠 Project Info:  http://localhost:$portLanding" -ForegroundColor Cyan
    Write-Host "   🌍 Joomla CMS:    http://localhost:$portJoomla" -ForegroundColor Cyan  
    Write-Host "   🗄️ phpMyAdmin:    http://localhost:$portPhpMyAdmin" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "🔐 Default Login Credentials:" -ForegroundColor White
    Write-Host "   Joomla Admin:  admin / (see .env file)" -ForegroundColor Green
    Write-Host "   phpMyAdmin:    root / (see .env file)" -ForegroundColor Green
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
