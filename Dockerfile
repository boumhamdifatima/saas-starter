# 1. Installation des dépendances
FROM node:20-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable
# --- AJOUT : Installation d'OpenSSL pour Prisma ---
RUN apt-get update -y && apt-get install -y openssl
# --------------------------------------------------
WORKDIR /app


#FROM base AS prod-deps
#RUN pnpm install --prod --frozen-lockfile

# 2. Build de l'application
FROM base AS build
# On copie les fichiers de configuration en premier (optimisation du cache Docker)
COPY package.json pnpm-lock.yaml ./

# On installe TOUTES les dépendances (nécessaire pour le build)
RUN pnpm install --frozen-lockfile

# Copie de tout le code source (incluant lib/db)
COPY . .

# ARGUMENTS de BUILD
ARG POSTGRES_URL
ARG NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
ARG NEXT_PUBLIC_APP_URL

# On lance le build Next.js
# On ajoute SKIP_ENV_VALIDATION au cas où ton template vérifie les variables d'env
# On lance le build Next.js avec une variable factice pour satisfaire le compilateur
RUN SKIP_ENV_VALIDATION=1 \
    POSTGRES_URL=postgresql://dummy:dummy@localhost:5432/dummy \
    STRIPE_SECRET_KEY=sk_test_dummy \
    STRIPE_WEBHOOK_SECRET=whsec_dummy \
    NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_dummy \
    NEXT_PUBLIC_APP_URL=http://localhost:3000 \
    pnpm run build

# 3. Image finale de production
FROM node:20-slim AS runner
# --- AJOUT : OpenSSL est aussi nécessaire ici pour l'exécution ---
RUN apt-get update -y && apt-get install -y openssl
# --------------------------------------------------------------
WORKDIR /app
ENV NODE_ENV=production

# On utilise une astuce pour ne pas planter si 'public' est absent
COPY --from=build /app/package.json ./package.json

# Cette ligne est la plus importante pour le mode standalone
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static

# Copie seulement si le dossier existe (on peut aussi simplement créer un dossier vide)
RUN mkdir -p public

# Si tu as vraiment des fichiers dans public, décommente la ligne suivante :
# COPY --from=build /app/public ./public 

EXPOSE 3000
CMD ["node", "server.js"]