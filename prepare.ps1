# Prepare Automated Joomla Master Project
# Prepares .env-example and creates .env file with correct project name

Write-Host "📋 Preparing Automated Joomla Master Project..." -ForegroundColor Green
Write-Host ""

# Check and fix .env-example if it contains CURRENT_FOLDER placeholder
if (Test-Path ".env-example") {
    $envExampleContent = Get-Content ".env-example" -Raw
    if ($envExampleContent -match '\$\{CURRENT_FOLDER\}') {
        Write-Host "📝 Updating .env-example with current folder name..." -ForegroundColor Cyan
        
        $currentFolderName = Split-Path -Leaf (Get-Location)
        
        # Validate folder name for Docker compatibility
        if ($currentFolderName -match "^[a-z0-9][a-z0-9_-]*$") {
            $envExampleContent = $envExampleContent -replace "\$\{CURRENT_FOLDER\}", $currentFolderName
            $envExampleContent | Set-Content ".env-example" -NoNewline
            Write-Host "✅ .env-example updated with PROJECT_NAME=$currentFolderName" -ForegroundColor Green
            Write-Host ""
        }
        else {
            Write-Host "❌ Folder name '$currentFolderName' is not Docker-compatible!" -ForegroundColor Red
            Write-Host "💡 Please rename folder to use only: lowercase letters, numbers, hyphens, underscores" -ForegroundColor Yellow
            Write-Host "   And must start with a letter or number" -ForegroundColor Yellow
            exit 1
        }
    }
    else {
        Write-Host "✅ .env-example is already prepared" -ForegroundColor Green
        Write-Host ""
    }
}
else {
    Write-Host "❌ .env-example file not found!" -ForegroundColor Red
    exit 1
}

# Create .env from template if it doesn't exist
if (-not (Test-Path ".env")) {
    Write-Host "📝 Creating .env from .env-example..." -ForegroundColor Cyan
    Copy-Item ".env-example" ".env"
    Write-Host "✅ Created .env file" -ForegroundColor Green
    Write-Host ""
    
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host "🔐 IMPORTANT: Please customize your passwords!" -ForegroundColor Yellow
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "📝 Edit the .env file and change these passwords:" -ForegroundColor White
    Write-Host "   • JOOMLA_ADMIN_PASSWORD (minimum 12 characters)" -ForegroundColor Cyan
    Write-Host "   • JOOMLA_DB_PASSWORD (minimum 12 characters)" -ForegroundColor Cyan
    Write-Host "   • MYSQL_ROOT_PASSWORD (minimum 12 characters)" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "⚠️  Avoid these characters: dollar-sign backtick quotes backslash §" -ForegroundColor Yellow
    Write-Host "✅ Good characters: A-Z a-z 0-9 - _ . + * # @ % & ( ) = ? !" -ForegroundColor Green
    Write-Host ""
    Write-Host "💡 After editing .env, run: .\start-project.ps1" -ForegroundColor Magenta
    Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
}
else {
    Write-Host "ℹ️  .env file already exists" -ForegroundColor Blue
    Write-Host "💡 You can run: .\start-project.ps1" -ForegroundColor Magenta
    Write-Host ""
}
