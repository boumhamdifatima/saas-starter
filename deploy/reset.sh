#!/bin/bash

echo "------------------------------------------"
echo "⚠️  NETTOYAGE COMPLET (HARD RESET)"
echo "------------------------------------------"

# 1. Arrêter les conteneurs et supprimer le réseau
echo "🛑 Arrêt des services..."
docker compose down --remove-orphans

# 2. Supprimer les volumes (La base de données sera effacée !)
echo "🗑️  Suppression des volumes (données DB)..."
docker compose down -v

# 3. Nettoyer le cache Docker et les images orphelines
echo "🧹 Nettoyage des caches et images inutilisées..."
docker system prune -af

echo "------------------------------------------"
echo "✨ Système nettoyé. Vous pouvez relancer ./deploy.sh"
echo "------------------------------------------"
