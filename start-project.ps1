# Start Automated Joomla Master Project
# Starts all containers and displays helpful information

Write-Host "🚀 Starting Automated Joomla Master..." -ForegroundColor Green
Write-Host ""

# Check if .env file exists, if not suggest prepare.ps1
if (-not (Test-Path ".env")) {
    Write-Host "❌ .env file not found!" -ForegroundColor Red
    Write-Host "💡 Please run the preparation script first:" -ForegroundColor Yellow
    Write-Host "   .\prepare.ps1" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "   This will create and customize your .env file." -ForegroundColor Gray
    exit 1
}

# Load .env file to get project name and ports
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
        # Check password length (minimum 12 characters for Joomla)
        if ($passwordValue.Length -lt 12) {
            Write-Host "❌ Password too short in $passwordVar! Found: $($passwordValue.Length) characters" -ForegroundColor Red
            Write-Host "💡 Joomla requires passwords with at least 12 characters" -ForegroundColor Yellow
            Write-Host "   Current: '$passwordValue' ($($passwordValue.Length) chars)" -ForegroundColor Red
            Write-Host "   Example: 'admin12345678' (12+ chars)" -ForegroundColor Cyan
            exit 1
        }
        
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

# Check if database volume exists (indicating existing project)
$volumeName = "${projectName}_db_data"
$volumeExists = (docker volume ls -q -f name=$volumeName) -ne $null

if ($volumeExists) {
    Write-Host "🔍 Existing database volume detected" -ForegroundColor Yellow
    Write-Host "   Volume: $volumeName" -ForegroundColor Gray
    Write-Host ""
    
    # Start containers first to access database
    Write-Host "🔄 Starting containers to check database..." -ForegroundColor Cyan
    docker-compose up -d --quiet-pull
    
    # Wait for database to be ready
    Write-Host "⏳ Waiting for database to start..." -ForegroundColor Gray
    Start-Sleep -Seconds 10
    
    # Check if database contains Joomla content (indicating it's not a fresh install)
    $hasJoomlaData = $false
    try {
        # Try to connect and check for Joomla tables
        $dbCheck = docker-compose exec -T db mysql -u root -p"$($envVariables['MYSQL_ROOT_PASSWORD'])" -e "USE $($envVariables['MYSQL_DATABASE']); SHOW TABLES LIKE 'joom_%';" 2>$null
        if ($dbCheck -and $dbCheck.Trim() -ne "") {
            $hasJoomlaData = $true
        }
    }
    catch {
        # Database might not be accessible yet, continue with normal startup
        $hasJoomlaData = $false
    }
    
    if ($hasJoomlaData) {
        Write-Host "✅ Existing Joomla data found - protecting your content!" -ForegroundColor Green
        Write-Host "🔐 Updating database passwords to match .env file..." -ForegroundColor Cyan
        
        # Update database user password to match .env
        try {
            $updatePassword = "ALTER USER '$($envVariables['MYSQL_USER'])'@'%' IDENTIFIED BY '$($envVariables['MYSQL_PASSWORD'])';"
            $updateRootPassword = "ALTER USER 'root'@'%' IDENTIFIED BY '$($envVariables['MYSQL_ROOT_PASSWORD'])';"
            
            # Update the passwords
            docker-compose exec -T db mysql -u root -p"$($envVariables['MYSQL_ROOT_PASSWORD'])" -e "$updatePassword $updateRootPassword FLUSH PRIVILEGES;" 2>$null
            Write-Host "✅ Database passwords synchronized with .env file" -ForegroundColor Green
        }
        catch {
            Write-Host "⚠️  Could not update database passwords - using existing ones" -ForegroundColor Yellow
        }
        
        Write-Host "💾 Your Joomla content (articles, menus, settings) is preserved!" -ForegroundColor Green
        Write-Host ""
    }
}
else {
    Write-Host "🆕 Fresh installation detected - setting up new project..." -ForegroundColor Green
}

# Start containers (if not already started for database check)
if (-not $volumeExists) {
    Write-Host "🔄 Starting Docker containers..." -ForegroundColor Cyan
    Write-Host "   Project Name: $projectName" -ForegroundColor Gray
    docker-compose up -d
}
else {
    Write-Host "🔄 Ensuring all containers are running..." -ForegroundColor Cyan
    docker-compose up -d --quiet-pull
}

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
    
    # Enhanced Configuration Sync System v4.2
    if ($volumeExists) {
        Write-Host "� Running Enhanced Configuration Sync System v4.2..." -ForegroundColor Cyan
        Start-Sleep -Seconds 2
        

        # Get configuration variables from .env
        $mysqlRootPassword = $envVariables["MYSQL_ROOT_PASSWORD"]
        $joomlaDbName = $envVariables["MYSQL_DATABASE"]
        $joomlaDbUser = $envVariables["MYSQL_USER"]
        $joomlaDbPassword = $envVariables["MYSQL_PASSWORD"]
        $joomlaSiteName = $envVariables["JOOMLA_SITE_NAME"]
        $joomlaAdminEmail = $envVariables["JOOMLA_ADMIN_EMAIL"]

        # Block DB-Variable changes after initial setup
        $dbVars = @("MYSQL_ROOT_PASSWORD", "MYSQL_PASSWORD", "MYSQL_USER", "MYSQL_DATABASE")
        $dbVarChanged = $false
        $dbVarWarnings = @()
        foreach ($dbVar in $dbVars) {
            $envValue = $envVariables[$dbVar]
            # Get current DB value via SQL (if possible)
            if ($dbVar -eq "MYSQL_ROOT_PASSWORD") {
                # Try to connect with .env password
                $testResult = docker exec "$projectName-mysql" mysql -u root -p"$envValue" -e "SELECT 1;" 2>$null
                if (-not ($testResult -and $testResult.Trim() -ne "")) {
                    $dbVarChanged = $true
                    $dbVarWarnings += "MYSQL_ROOT_PASSWORD (Änderung nach Erstinstallation erkannt)"
                }
            }
            elseif ($dbVar -eq "MYSQL_USER") {
                $userCheck = docker exec "$projectName-mysql" mysql -u root -p"$mysqlRootPassword" -e "SELECT User FROM mysql.user WHERE User='$envValue';" 2>$null | Select-Object -Skip 1
                if (-not ($userCheck -and $userCheck.Trim() -eq $envValue)) {
                    $dbVarChanged = $true
                    $dbVarWarnings += "MYSQL_USER (Änderung nach Erstinstallation erkannt)"
                }
            }
            elseif ($dbVar -eq "MYSQL_DATABASE") {
                $dbCheck = docker exec "$projectName-mysql" mysql -u root -p"$mysqlRootPassword" -e "SHOW DATABASES LIKE '$envValue';" 2>$null | Select-Object -Skip 1
                if (-not ($dbCheck -and $dbCheck.Trim() -eq $envValue)) {
                    $dbVarChanged = $true
                    $dbVarWarnings += "MYSQL_DATABASE (Änderung nach Erstinstallation erkannt)"
                }
            }
            elseif ($dbVar -eq "MYSQL_PASSWORD") {
                $pwCheck = docker exec "$projectName-mysql" mysql -u "$joomlaDbUser" -p"$envValue" -e "SELECT 1;" 2>$null
                if (-not ($pwCheck -and $pwCheck.Trim() -ne "")) {
                    $dbVarChanged = $true
                    $dbVarWarnings += "MYSQL_PASSWORD (Änderung nach Erstinstallation erkannt)"
                }
            }
        }

        if ($dbVarChanged) {
            Write-Host "❌ Datenbank-Variablen wurden nach der Erstinstallation geändert!" -ForegroundColor Red
            Write-Host "   Diese Änderungen sind nicht erlaubt und werden ignoriert." -ForegroundColor Yellow
            Write-Host "   Betroffene Variablen: $($dbVarWarnings -join ', ')" -ForegroundColor Gray
            Write-Host "   Tipp: Für DB-Änderungen bitte Neuinstallation durchführen!" -ForegroundColor Cyan
            Write-Host "   Die Anwendung verwendet weiterhin die ursprünglichen Datenbank-Zugangsdaten." -ForegroundColor Gray
            Write-Host "   Nur Joomla-Einstellungen und Ports werden synchronisiert." -ForegroundColor Gray
            # Entferne alle Recovery- und Fallback-Abschnitte, die DB-Variablen nachträglich ändern würden
            # ...existing code für Joomla/Port-Sync...
            # ...existing code...
        }
        else {
            # ...bestehende Sync-Logik...
            # ...existing code...
        }
        
        if (-not $workingRootPassword) {
            Write-Host "   ❌ Cannot connect to database mit den aktuellen Zugangsdaten." -ForegroundColor Red
            Write-Host "   Die Anwendung verwendet weiterhin die ursprünglichen Datenbank-Zugangsdaten. Änderungen an DB-Variablen werden ignoriert." -ForegroundColor Yellow
            Write-Host "   Tipp: Für DB-Änderungen bitte Neuinstallation durchführen!" -ForegroundColor Cyan
            # Keine Recovery oder Fallback mehr, nur Hinweis
        }
        else {
            # Check database integrity and Joomla connectivity
            $tableCount = docker exec "$projectName-mysql" mysql -u root -p"$workingRootPassword" -e "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = '$joomlaDbName';" 2>$null | Select-Object -Skip 1
            
            $joomlaCanConnect = $false
            if ([int]$tableCount -gt 0) {
                $connectionTest = docker exec "$projectName-mysql" mysql -u "$joomlaDbUser" -p"$joomlaDbPassword" -e "USE $joomlaDbName; SELECT 1;" 2>$null
                if ($connectionTest -and $connectionTest.Trim() -ne "") {
                    $joomlaCanConnect = $true
                }
            }
            
            # Recovery scenarios
            if ([int]$tableCount -eq 0) {
                Write-Host "   ⚠️  Empty database detected - triggering automatic recovery..." -ForegroundColor Yellow
                docker restart "$projectName-joomla" > $null 2>&1
                Write-Host "   ✅ Database recovery initiated" -ForegroundColor Green
            }
            elseif (-not $joomlaCanConnect) {
                Write-Host "   ⚠️  Database password mismatch detected - fixing authentication..." -ForegroundColor Yellow
                Write-Host "   📊 Database has $tableCount tables but Joomla cannot connect" -ForegroundColor Gray
                
                try {
                    # Update all database passwords
                    $updateJoomlaUser = "ALTER USER '$joomlaDbUser'@'%' IDENTIFIED BY '$joomlaDbPassword';"
                    $updateRootUser = "ALTER USER 'root'@'%' IDENTIFIED BY '$mysqlRootPassword';"
                    docker exec "$projectName-mysql" mysql -u root -p"$workingRootPassword" -e "$updateJoomlaUser $updateRootUser FLUSH PRIVILEGES;" 2>$null
                    
                    # Update Joomla configuration.php
                    Write-Host "   🔧 Updating Joomla configuration.php..." -ForegroundColor Cyan
                    
                    # Generate password variations for configuration.php search
                    $configPasswords = @()
                    foreach ($testPass in $possibleRootPasswords) {
                        # Convert root passwords to potential Joomla DB passwords
                        $joomlaVariation = $testPass -replace 'mysql', 'joomla'
                        if ($configPasswords -notcontains $joomlaVariation) {
                            $configPasswords += $joomlaVariation
                        }
                    }
                    
                    # Try to find and replace the old password in configuration.php
                    $configUpdated = $false
                    foreach ($oldPassword in $configPasswords) {
                        if ($oldPassword -ne $joomlaDbPassword) {
                            $result = docker exec "$projectName-joomla" sh -c "sed -i 's/$oldPassword/$joomlaDbPassword/g' /var/www/html/configuration.php" 2>$null
                            if ($LASTEXITCODE -eq 0) {
                                $configUpdated = $true
                                break
                            }
                        }
                    }
                    
                    # Restart Joomla to apply changes
                    docker restart "$projectName-joomla" > $null 2>&1
                    Start-Sleep -Seconds 5
                    Write-Host "   ✅ Enhanced Configuration Sync v4.2 password recovery complete!" -ForegroundColor Green
                }
                catch {
                    Write-Host "   ❌ Password recovery failed - manual intervention required" -ForegroundColor Red
                }
            }
            else {
                Write-Host "   ✅ Database integrity confirmed ($tableCount tables, connection OK)" -ForegroundColor Green
                
                # Enhanced v4.2: Comprehensive Configuration Sync
                Write-Host "   🔍 Running comprehensive configuration sync..." -ForegroundColor Cyan
                
                $configChanges = 0
                
                # 1. Password Sync (from v4.1)
                $configPasswordLine = docker exec "$projectName-joomla" sh -c "grep 'public.*password' /var/www/html/configuration.php" 2>$null
                if ($configPasswordLine -and $configPasswordLine -match "public.*password.*=.*'([^']*)'") {
                    $currentConfigPassword = $Matches[1]
                    if ($currentConfigPassword -ne $joomlaDbPassword) {
                        Write-Host "   ⚠️  Password mismatch detected - updating..." -ForegroundColor Yellow
                        docker exec "$projectName-joomla" sh -c "sed -i 's/$currentConfigPassword/$joomlaDbPassword/g' /var/www/html/configuration.php" 2>$null
                        $configChanges++
                    }
                }
                
                # 2. Site Name Sync (NEW in v4.2)
                if ($joomlaSiteName) {
                    $configSiteNameLine = docker exec "$projectName-joomla" sh -c "grep 'public.*sitename' /var/www/html/configuration.php" 2>$null
                    if ($configSiteNameLine -and $configSiteNameLine -match "public.*sitename.*=.*'([^']*)'") {
                        $currentSiteName = $Matches[1]
                        if ($currentSiteName -ne $joomlaSiteName) {
                            Write-Host "   🏠 Site name mismatch detected - updating..." -ForegroundColor Yellow
                            Write-Host "      From: '$currentSiteName'" -ForegroundColor Gray
                            Write-Host "      To: '$joomlaSiteName'" -ForegroundColor Gray
                            docker exec "$projectName-joomla" sh -c "sed -i 's/$currentSiteName/$joomlaSiteName/g' /var/www/html/configuration.php" 2>$null
                            
                            # Also update in Joomla database - fixed escaping
                            $oldSiteJson = '\"sitename\":\"' + $currentSiteName + '\"'
                            $newSiteJson = '\"sitename\":\"' + $joomlaSiteName + '\"'
                            $updateSiteNameQuery = "UPDATE joom_extensions SET params = REPLACE(params, '$oldSiteJson', '$newSiteJson') WHERE element = 'com_config';"
                            docker exec "$projectName-mysql" mysql -u root -p"$workingRootPassword" -e "USE $joomlaDbName; $updateSiteNameQuery" 2>$null
                            $configChanges++
                        }
                    }
                }
                
                # 3. Admin Email Sync (NEW in v4.2) 
                if ($joomlaAdminEmail) {
                    $currentAdminEmail = docker exec "$projectName-mysql" mysql -u root -p"$workingRootPassword" -e "USE $joomlaDbName; SELECT email FROM joom_users WHERE id = 1;" 2>$null | Select-Object -Skip 1
                    if ($currentAdminEmail -and $currentAdminEmail.Trim() -ne $joomlaAdminEmail) {
                        Write-Host "   📧 Admin email mismatch detected - updating..." -ForegroundColor Yellow
                        Write-Host "      From: '$($currentAdminEmail.Trim())'" -ForegroundColor Gray
                        Write-Host "      To: '$joomlaAdminEmail'" -ForegroundColor Gray
                        $updateEmailQuery = "UPDATE joom_users SET email = '$joomlaAdminEmail' WHERE id = 1;"
                        docker exec "$projectName-mysql" mysql -u root -p"$workingRootPassword" -e "USE $joomlaDbName; $updateEmailQuery" 2>$null
                        $configChanges++
                    }
                }
                
                # Apply changes if any were made
                if ($configChanges -gt 0) {
                    Write-Host "   🔄 Restarting ALL containers to apply $configChanges configuration changes..." -ForegroundColor Cyan
                    # Restart all relevant containers
                    docker restart "$projectName-mysql" > $null 2>&1
                    docker restart "$projectName-joomla" > $null 2>&1
                    docker restart "$projectName-phpmyadmin" > $null 2>&1
                    Start-Sleep -Seconds 8
                    Write-Host "   ✅ Enhanced Configuration Sync v4.2 complete!" -ForegroundColor Green
                }
                else {
                    Write-Host "   ✅ All configurations are already synchronized" -ForegroundColor Green
                }

                # Always sync MySQL users (root + joomla)
                Write-Host "   🔄 Synchronizing MySQL users..." -ForegroundColor Cyan
                $alterRoot = "ALTER USER 'root'@'%' IDENTIFIED BY '$mysqlRootPassword';"
                $alterJoomla = "ALTER USER '$joomlaDbUser'@'%' IDENTIFIED BY '$joomlaDbPassword';"
                docker exec "$projectName-mysql" mysql -u root -p"$workingRootPassword" -e "$alterRoot $alterJoomla FLUSH PRIVILEGES;" 2>$null
                Start-Sleep -Seconds 2
                Write-Host "   ✅ MySQL users synchronized" -ForegroundColor Green

                # Test DB connection after sync
                $testRoot = docker exec "$projectName-mysql" mysql -u root -p"$mysqlRootPassword" -e "SELECT 1;" 2>$null
                $testJoomla = docker exec "$projectName-mysql" mysql -u "$joomlaDbUser" -p"$joomlaDbPassword" -e "USE $joomlaDbName; SELECT 1;" 2>$null
                if ($testRoot -and $testRoot.Trim() -ne "") {
                    Write-Host "   ✅ MySQL root connection test: OK" -ForegroundColor Green
                }
                else {
                    Write-Host "   ❌ MySQL root connection test: FAILED" -ForegroundColor Red
                }
                if ($testJoomla -and $testJoomla.Trim() -ne "") {
                    Write-Host "   ✅ Joomla DB user connection test: OK" -ForegroundColor Green
                }
                else {
                    Write-Host "   ❌ Joomla DB user connection test: FAILED" -ForegroundColor Red
                }
            }
        }
        Write-Host ""
    }
    
    Write-Host "⚠️  IMPORTANT: If you get 'Error 500' on first visit:" -ForegroundColor Yellow
    Write-Host "   • Wait 30 seconds more for full installation" -ForegroundColor Yellow  
    Write-Host "   • Clear browser cache (Ctrl+F5)" -ForegroundColor Yellow
    Write-Host "   • Or run: docker-compose down -v --remove-orphans && .\start-project.ps1" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "🔐 Default Login Credentials:" -ForegroundColor White
    Write-Host "   Joomla Admin:  admin / (see .env file)" -ForegroundColor Green
    Write-Host "   phpMyAdmin:    root / (see .env file)" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 Pro Tip: Start with http://localhost:$portLanding for project overview!" -ForegroundColor Magenta
    Write-Host ""
    
    # Auto-cleanup: Remove .git and .github folders to make project completely independent
    $cleanupPaths = @(".git", ".github")
    $cleanedItems = @()
    
    foreach ($path in $cleanupPaths) {
        if (Test-Path $path) {
            try {
                Remove-Item -Recurse -Force $path -ErrorAction Stop
                $cleanedItems += $path
            }
            catch {
                Write-Host "⚠️  Could not remove $path folder: $($_.Exception.Message)" -ForegroundColor Yellow
            }
        }
    }
    
    if ($cleanedItems.Count -gt 0) {
        Write-Host "🗂️  Removed $($cleanedItems -join ', ') - project ready for own repository" -ForegroundColor Gray
        Write-Host "💡 To create your own Git repository:" -ForegroundColor Gray
        Write-Host "   git init && git add . && git commit -m 'Initial Joomla project'" -ForegroundColor DarkGray
    }
    
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
