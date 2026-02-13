# 1. Installation des dépendances
FROM node:20-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
COPY . /app
WORKDIR /app

FROM base AS prod-deps
RUN pnpm install --prod --frozen-lockfile

# 2. Build de l'application
FROM base AS build
RUN pnpm install --frozen-lockfile
# On passe les variables d'environnement nécessaires au build
ARG POSTGRES_URL
ARG STRIPE_SECRET_KEY
RUN pnpm run build

# ... (étapes précédentes inchangées)

# 3. Image finale de production
FROM node:20-slim AS runner
WORKDIR /app
ENV NODE_ENV=production

# On utilise une astuce pour ne pas planter si 'public' est absent
COPY --from=build /app/package.json ./package.json

# Copie seulement si le dossier existe (on peut aussi simplement créer un dossier vide)
RUN mkdir -p public

# Cette ligne est la plus importante pour le mode standalone
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static

# Si tu as vraiment des fichiers dans public, décommente la ligne suivante :
# COPY --from=build /app/public ./public 

EXPOSE 3000
CMD ["node", "server.js"]