#!/bin/sh

# Check if .env file exists
if [ ! -f .env ]; then
    echo "No .env file found, copying from .env.example..."
    cp .env.example .env
else
    echo ".env file already exists."
fi

rm -rf node_modules

# Run docker compose
docker compose up --build
