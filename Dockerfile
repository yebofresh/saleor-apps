FROM node:18-alpine AS deps
RUN apk add --no-cache libc6-compat
WORKDIR /app
COPY package.json package-lock.json ./
RUN npm ci

FROM node:18-alpine AS builder

ARG NUVO_API_KEY

ENV NEXT_PUBLIC_NUVO_LICENSE_KEY=${NUVO_API_KEY:-0000000000}

WORKDIR /

COPY --from=deps /node_modules ./node_modules

COPY . .

RUN pnpm build

FROM node:18-alpine AS runner
WORKDIR /

ENV NODE_ENV production

RUN addgroup --system --gid 1001 yebobuild
RUN adduser --system --uid 1001 yebobuild

#COPY --from=builder /app/public ./public
COPY --from=builder /package.json ./package.json

#COPY --from=builder --chown=yebobuild:yebobuild /app/.next/standalone ./
#COPY --from=builder --chown=yebobuild:yebobuild /app/.next/static ./.next/static

USER yebobuild

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]