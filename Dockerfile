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

# 3. Image finale de production
FROM node:20-slim AS runner
WORKDIR /app
ENV NODE_ENV=production
COPY --from=build /app/public ./public
COPY --from=build /app/.next/standalone ./
COPY --from=build /app/.next/static ./.next/static

EXPOSE 3000
CMD ["node", "server.js"]