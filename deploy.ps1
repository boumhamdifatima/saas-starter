# Définition des paramètres
param (
    [string]$User = "regestryuser",
    [string]$Repo = "saas-starter"
)

# Génération d'un tag basé sur la date (ex: 20260220-1430)
$DATE_TAG = Get-Date -Format "yyyyMMdd-HHmm"
$IMAGE_BASE = "ghcr.io/$($User.ToLower())/$($Repo.ToLower())"

Write-Host "🚀 Début du build pour l'image : ${IMAGE_BASE}:${DATE_TAG}" -ForegroundColor Cyan

# 1. Build de l'image avec le tag daté
# On utilise ${} pour éviter que PowerShell ne confonde le ':' avec un lecteur
docker build -t "${IMAGE_BASE}:${DATE_TAG}" .

if ($LASTEXITCODE -ne 0) { 
    Write-Host "❌ Erreur lors du build !" -ForegroundColor Red
    exit $LASTEXITCODE 
}

# 2. Création du tag 'latest'
Write-Host "🏷️ Tagging en tant que 'latest'..." -ForegroundColor Yellow
docker tag "${IMAGE_BASE}:${DATE_TAG}" "${IMAGE_BASE}:latest"

# 3. Push des deux versions
Write-Host "⬆️ Envoi des images vers GHCR..." -ForegroundColor Magenta
docker push "${IMAGE_BASE}:${DATE_TAG}"
docker push "${IMAGE_BASE}:latest"

Write-Host "✅ Terminé ! Image disponible sur ${IMAGE_BASE}" -ForegroundColor Green