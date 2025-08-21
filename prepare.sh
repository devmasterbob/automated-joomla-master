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
    # Set PROJECT_NAME and COMPOSE_PROJECT_NAME in .env (directly after creation)
    current_folder=$(basename "$PWD")
    sed -i "s/^PROJECT_NAME=.*/PROJECT_NAME=$current_folder/" .env
    sed -i "s/^COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME=$current_folder/" .env
    # ...existing code...
else
    echo "[INFO] .env file already exists"
    current_folder=$(basename "$PWD")
    sed -i "s/^PROJECT_NAME=.*/PROJECT_NAME=$current_folder/" .env
    sed -i "s/^COMPOSE_PROJECT_NAME=.*/COMPOSE_PROJECT_NAME=$current_folder/" .env
    echo "[TIP] You can run: ./start-project.sh"
    echo ""
fi

# Check for port conflicts before finishing
if [ -f ".env" ]; then
    echo "[CHECK] Checking for port conflicts..."
    if ! command -v ss &> /dev/null; then
        echo "⚠️  'ss' command not found! Port check skipped."
    else
        grep -E "^PORT_[A-Z]+=[0-9]+$" .env | while IFS='=' read -r key port; do
            if ss -tuln | grep -q ":$port "; then
                echo "⚠️  Port $port ($key) is already in use! Please choose a free port in .env."
            fi
        done
    fi
    echo ""
fi

echo "[DONE] Preparation finished!"