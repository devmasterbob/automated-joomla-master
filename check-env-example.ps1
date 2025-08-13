# Protect .env-example from accidental overwrite
# Run this before committing to ensure .env-example keeps ${CURRENT_FOLDER}

Write-Host "🔒 Checking .env-example protection..." -ForegroundColor Cyan

$envExamplePath = ".env-example"
if (Test-Path $envExamplePath) {
    $content = Get-Content $envExamplePath -Raw
    
    if ($content -match "PROJECT_NAME=\$\{CURRENT_FOLDER\}") {
        Write-Host "✅ .env-example is protected - contains \${CURRENT_FOLDER}" -ForegroundColor Green
    }
    else {
        Write-Host "⚠️  WARNING: .env-example may be corrupted!" -ForegroundColor Yellow
        Write-Host "   Expected: PROJECT_NAME=\${CURRENT_FOLDER}" -ForegroundColor Gray
        
        # Check what it actually contains
        $projectNameLine = $content | Select-String "PROJECT_NAME=" | Select-Object -First 1
        if ($projectNameLine) {
            Write-Host "   Found: $($projectNameLine.Line)" -ForegroundColor Gray
        }
        
        $fix = Read-Host "❓ Fix automatically? (y/N)"
        if ($fix -eq 'y' -or $fix -eq 'Y') {
            # Fix the PROJECT_NAME line
            $fixedContent = $content -replace "PROJECT_NAME=.*", "PROJECT_NAME=`${CURRENT_FOLDER}"
            Set-Content -Path $envExamplePath -Value $fixedContent -Encoding UTF8
            Write-Host "✅ Fixed! .env-example now contains \${CURRENT_FOLDER}" -ForegroundColor Green
        }
    }
}
else {
    Write-Host "❌ .env-example not found!" -ForegroundColor Red
}

Write-Host ""
