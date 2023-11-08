FROM node:18-alpine AS runner

ARG NUVO_API_KEY
ENV NEXT_PUBLIC_NUVO_LICENSE_KEY=${NUVO_API_KEY:-0000000000}

RUN apk add --no-cache libc6-compat
RUN npm install -g pnpm

COPY . .

RUN pnpm install --frozen-lockfile

RUN pnpm build --filter=saleor-app-data-importer

ENV NODE_ENV production

RUN addgroup --system --gid 1001 yebobuild
RUN adduser --system --uid 1001 yebobuild

USER yebobuild

EXPOSE 3000

ENV PORT 3000

CMD ["node", "server.js"]