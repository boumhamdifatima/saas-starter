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
# On installe TOUTES les dépendances (nécessaire pour le build)
RUN pnpm install --frozen-lockfile

# ARGUMENTS de BUILD
ARG POSTGRES_URL
ARG NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
ARG NEXT_PUBLIC_APP_URL

# ASTUCE : On génère le client Prisma AVANT le build
# Cela permet à Next.js de compiler même si la DB est hors-ligne
RUN npx prisma generate

# On lance le build
# Note: Si le build plante à cause de la validation d'env, 
# on peut ajouter SKIP_ENV_VALIDATION=1 devant la commande
RUN pnpm run build

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