#!/bin/bash

echo "🚀 Prepare Automated Joomla Master Project"

# Set PROJECT_NAME and COMPOSE_PROJECT_NAME in .env
current_folder=$(basename "$PWD")
if [ -f ".env" ]; then
    sed -i "s/^PROJECT_NAME=.*/PROJECT_NAME=$current_folder/" .env
    sed -i "s/^COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME=$current_folder/" .env
fi

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
    grep -E "^PORT_[A-Z]+=[0-9]+$" .env | while IFS='=' read -r key port; do
        if ss -tuln | grep -q ":$port "; then
            echo "⚠️  Port $port ($key) is already in use! Please choose a free port in .env."
        fi
    done
    echo ""
fi