#!/bin/bash

# Configuration
IMAGE_NAME="ghcr.io/boumhamdifatima/saas-starter:latest"
DB_URL="postgresql://devuser:devpassword@db:5432/saas_db"

echo "------------------------------------------"
echo "🚀 DÉBUT DU DÉPLOIEMENT"
echo "------------------------------------------"

# 1. Mise à jour de l'image
echo "📥 Récupération de la dernière version..."
docker compose pull app

# 2. S'assurer que la DB tourne
echo "🐘 Vérification de la base de données..."
docker compose up -d db

# 3. Attendre que la DB soit prête à accepter des connexions
echo "⏳ Attente de PostgreSQL..."
until docker exec saas-db pg_isready -U devuser -d saas_db; do
  sleep 2
done

# 4. MISE À JOUR DU SCHÉMA (La partie magique)
echo "🔄 Synchronisation du schéma Drizzle..."
docker compose run --rm app npx drizzle-kit push --dialect=postgresql --schema=./lib/db/schema.ts --url="$DB_URL"

# 5. Redémarrage de l'application
echo "🆙 Relancement de l'application..."
docker compose up -d app

# 6. Nettoyage
echo "🧹 Nettoyage des vieilles images..."
docker image prune -f

echo "------------------------------------------"
echo "✅ DÉPLOIEMENT RÉUSSI !"
echo "------------------------------------------"
