# Stage 1: Compile Metric-FF planner
FROM ubuntu:24.04 AS planner

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc libc6-dev make flex bison git ca-certificates \
  && rm -rf /var/lib/apt/lists/*

RUN git clone --depth 1 https://github.com/caelan/Metric-FF.git /metric-ff

WORKDIR /metric-ff
RUN sed -i 's/int errno,/int errnum,/g' scan-fct_pddl.y scan-ops_pddl.y \
  && sed -i 's/-O6 -ansi/-O2/g' makefile \
  && sed -i 's/$(ADDONS) -g/$(ADDONS) -g -Wno-format-overflow -fcommon/' makefile \
  && make clean && make

# Stage 2: Build SvelteKit
FROM node:22-slim AS build

WORKDIR /app/web
COPY web/package.json web/package-lock.json ./
RUN npm ci

COPY web/ ./
RUN npm run build && npm prune --production

# Stage 3: Runtime
FROM node:22-slim

RUN apt-get update && apt-get install -y --no-install-recommends python3 \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

COPY Basico/ ./Basico/
COPY Extension_1/ ./Extension_1/
COPY Extension_2/ ./Extension_2/
COPY Extension_3/ ./Extension_3/
COPY Extension_4/ ./Extension_4/
COPY Extra_2/ ./Extra_2/

WORKDIR /app/web

COPY --from=build /app/web/build ./build/
COPY --from=build /app/web/node_modules ./node_modules/
COPY --from=build /app/web/package.json ./
COPY web/generator.py ./

RUN mkdir -p tools/metric-ff
COPY --from=planner /metric-ff/ff ./tools/metric-ff/ff

ENV NODE_ENV=production
ENV PORT=3000
EXPOSE 3000

CMD ["node", "build/index.js"]
