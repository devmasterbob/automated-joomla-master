#!/bin/bash

echo "🚀 Prepare Automated Joomla Master Project"

# Create .env from template if it doesn't exist
if [ ! -f ".env" ]; then
    echo "[CREATE] Creating .env from .env-example..."
    cp .env-example .env
    echo "[SUCCESS] Created .env file"
    echo ""
    echo "================================================================="
    echo "[IMPORTANT] Please customize your passwords!"
    echo "================================================================="
    echo ""
    echo "[EDIT] Edit the .env file and change these passwords:"
    echo "   * JOOMLA_ADMIN_PASSWORD (minimum 12 characters)"
    echo "   * JOOMLA_DB_PASSWORD (minimum 12 characters)"
    echo "   * MYSQL_ROOT_PASSWORD (minimum 12 characters)"
    echo ""
    echo "[WARNING] Avoid problematic characters: dollar-sign, backtick, quotes, backslash, section-sign"
    echo "[OK] Good characters: A-Z a-z 0-9 - _ . + * # @ % & ( ) = ? !"
    echo ""
    echo "[TIP] After editing .env, run: ./start-project.sh"
    echo "================================================================="
else
    echo "[INFO] .env file already exists"
    echo "[TIP] You can run: ./start-project.sh"
    echo ""
fi

# Check for port conflicts before finishing
if [ -f ".env" ]; then
    echo "[CHECK] Checking for port conflicts..."
    while IFS= read -r line; do
        if [[ $line =~ ^PORT_([A-Z]+)=(.*)$ ]]; then
            portName="${BASH_REMATCH[1]}"
            port="${BASH_REMATCH[2]}"
            if ss -tuln | grep -q ":$port "; then
                echo "⚠️  Port $port ($portName) is already in use! Please choose a free port in .env."
            fi
        fi
    done < .env
    echo ""
fi