FROM node:18-alpine AS deps
RUN apk add --no-cache libc6-compat

# Install pnpm
RUN npm install -g pnpm

COPY . .

RUN pnpm install

FROM node:18-alpine AS builder

ARG NUVO_API_KEY

ENV NEXT_PUBLIC_NUVO_LICENSE_KEY=${NUVO_API_KEY:-0000000000}

COPY --from=deps /node_modules ./node_modules

COPY . .

RUN pnpm build

FROM node:18-alpine AS runner

ENV NODE_ENV production

RUN addgroup --system --gid 1001 yebobuild
RUN adduser --system --uid 1001 yebobuild

COPY --from=builder /apps ./apps
COPY --from=builder /package.json ./package.json

#COPY --from=builder --chown=yebobuild:yebobuild /app/.next/standalone ./
#COPY --from=builder --chown=yebobuild:yebobuild /app/.next/static ./.next/static

USER yebobuild

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]