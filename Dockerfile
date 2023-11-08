FROM node:18-alpine AS deps
RUN apk add --no-cache libc6-compat
RUN npm install -g pnpm

COPY . .

RUN pnpm install --frozen-lockfile

FROM node:18-alpine AS builder

RUN npm install -g pnpm

ARG NUVO_API_KEY

ENV NEXT_PUBLIC_NUVO_LICENSE_KEY=${NUVO_API_KEY:-0000000000}

#COPY --from=deps /node_modules ./node_modules
COPY --from=deps . .

RUN pnpm build --filter=saleor-app-data-importer

FROM node:18-alpine AS runner

ENV NODE_ENV production

RUN addgroup --system --gid 1001 yebobuild
RUN adduser --system --uid 1001 yebobuild

COPY --from=builder . .

#COPY --from=builder --chown=yebobuild:yebobuild /app/.next/standalone ./
#COPY --from=builder --chown=yebobuild:yebobuild /app/.next/static ./.next/static

USER yebobuild

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]