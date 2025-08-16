# Prepare Automated Joomla Master Project
# Prepares .env-example and creates .env file with correct project name

Write-Host "[INFO] Preparing Automated Joomla Master Project..." -ForegroundColor Green
Write-Host ""

# Check and fix .env-example if it contains CURRENT_FOLDER placeholder
if (Test-Path ".env-example") {
    $envExampleContent = Get-Content ".env-example" -Raw
    if ($envExampleContent -match '\$\{CURRENT_FOLDER\}') {
        Write-Host "[UPDATE] Updating .env-example with current folder name..." -ForegroundColor Cyan
        
        $currentFolderName = Split-Path -Leaf (Get-Location)
        
        # Validate folder name for Docker compatibility
        if ($currentFolderName -match "^[a-z0-9][a-z0-9_-]*$") {
            $envExampleContent = $envExampleContent -replace "\$\{CURRENT_FOLDER\}", $currentFolderName
            $envExampleContent | Set-Content ".env-example" -NoNewline
            Write-Host "[SUCCESS] .env-example updated with PROJECT_NAME=$currentFolderName" -ForegroundColor Green
            Write-Host ""
        }
        else {
            Write-Host "[ERROR] Folder name '$currentFolderName' is not Docker-compatible!" -ForegroundColor Red
            Write-Host "[TIP] Please rename folder to use only: lowercase letters, numbers, hyphens, underscores" -ForegroundColor Yellow
            Write-Host "      And must start with a letter or number" -ForegroundColor Yellow
            exit 1
        }
    }
    else {
        Write-Host "[SUCCESS] .env-example is already prepared" -ForegroundColor Green
        Write-Host ""
    }
}
else {
    Write-Host "[ERROR] .env-example file not found!" -ForegroundColor Red
    exit 1
}

# Create .env from template if it doesn't exist
if (-not (Test-Path ".env")) {
    Write-Host "[CREATE] Creating .env from .env-example..." -ForegroundColor Cyan
    Copy-Item ".env-example" ".env"
    Write-Host "[SUCCESS] Created .env file" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "=================================================================" -ForegroundColor Yellow
    Write-Host "[IMPORTANT] Please customize your passwords!" -ForegroundColor Yellow
    Write-Host "=================================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "[EDIT] Edit the .env file and change these passwords:" -ForegroundColor White
    Write-Host "   * JOOMLA_ADMIN_PASSWORD (minimum 12 characters)" -ForegroundColor Cyan
    Write-Host "   * JOOMLA_DB_PASSWORD (minimum 12 characters)" -ForegroundColor Cyan
    Write-Host "   * MYSQL_ROOT_PASSWORD (minimum 12 characters)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "[WARNING] Avoid these problematic characters: dollar-sign, backtick, quotes, backslash, section-sign" -ForegroundColor Yellow
    Write-Host "[OK] Good characters: A-Z a-z 0-9 - _ . + * # @ % & ( ) = ? !" -ForegroundColor Green
    Write-Host ""
    Write-Host "[TIP] After editing .env, run: .\start-project.ps1" -ForegroundColor Magenta
    Write-Host "=================================================================" -ForegroundColor Yellow
}
else {
    Write-Host "[INFO] .env file already exists" -ForegroundColor Blue
    Write-Host "[TIP] You can run: .\start-project.ps1" -ForegroundColor Magenta
    Write-Host ""
}


# Check for port conflicts before finishing
if (Test-Path ".env") {
    Write-Host "[CHECK] Checking for port conflicts..." -ForegroundColor Cyan
    $envContent = Get-Content ".env" | Where-Object { $_ -match "=" }
    $ports = @{}
    foreach ($line in $envContent) {
        if ($line -match "^PORT_(\w+)=(\d+)$") {
            $ports[$Matches[1]] = [int]$Matches[2]
        }
    }
    foreach ($portName in $ports.Keys) {
        $port = $ports[$portName]
        $tcpUsed = (Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue)
        if ($tcpUsed) {
            Write-Host "⚠️  Port $port ($portName) ist bereits belegt! Bitte einen freien Port in der .env wählen." -ForegroundColor Yellow
        }
    }
    Write-Host ""
}
