# Observability stack — LGTM + Pyroscope + Faro PoC

This directory holds the experimental observability stack for
`Practica_de_Planificacion`, deliberately separate from the existing
Sentry-on-Sentry.io setup. Both stacks coexist (see Phase 2 notes on
`@sentry/opentelemetry`) so the SvelteKit app emits to both during the
experiment, and the comparison artefact (`obs-experiment-notes.md`,
written in Phase 6) is grounded in real side-by-side data.

## Why a separate stack at all

The portfolio's main observability story is "Sentry hosted, low-friction,
narrow surface". This PoC asks the opposite question: *if a self-hosted,
open-source stack with broader signal coverage (logs, metrics, traces,
profiles, RUM) is the tool, what does the architecture look like?* The
goal is not to replace Sentry — it's to learn what each model is good at
and write that down.

## Architecture

```
                     ┌────────────────┐
                     │ Browser (Svelte)│
                     │ Faro Web SDK   │──── HTTP /collect ────┐
                     └────────────────┘                       │
                                                              ▼
┌──────────────────────┐  OTLP gRPC :4317  ┌─────────────────────────┐
│ SvelteKit Node server│ ────────────────▶ │ OTel Collector (contrib)│
│ - OTel NodeSDK       │  OTLP HTTP :4318  │ Pipelines: traces /     │
│ - @sentry/opentel    │ ────────────────▶ │   logs / metrics        │
│ - Pyroscope SDK ─────┼─── /push :4040 ──▶│ Faro receiver :12347    │
│ - Pino + OTel logs   │                   └────────┬────────────────┘
└──────────────────────┘                            │
                                                    │ traces  ▶ tempo:4317
                                                    │ logs    ▶ loki:3100/otlp
                                                    │ metrics ▶ mimir:9009/otlp
                                                    ▼
              ┌────────┐  ┌──────┐  ┌───────┐  ┌───────────┐
              │ Tempo  │  │ Loki │  │ Mimir │  │ Pyroscope │
              └───┬────┘  └──┬───┘  └───┬───┘  └─────┬─────┘
                  │          │          │            │
                  └──────────┴──────────┴────────────┘
                                 │
                                 ▼
                       MinIO (S3-compatible)
                       buckets: obs-tempo, obs-loki,
                                obs-mimir, obs-pyroscope

                       ┌─────────┐    ┌──────────────┐
                       │ Grafana │ ◀──┤ Alertmanager │
                       └─────────┘    └──────────────┘
```

Profiles bypass the Collector because the contrib distro doesn't yet have
a stable profile receiver; the Pyroscope Node SDK pushes directly. Faro is
a separate ingest port on the Collector (12347) rather than going through
OTLP, because the Faro envelope shape carries browser-specific fields that
the Faro receiver knows how to translate.

## Bring-up

```bash
cd observability
cp .env.obs.example .env.obs
docker compose -f docker-compose.obs.yml --env-file .env.obs up -d
```

First boot takes ~60 s — MinIO has to come up healthy before the four
storage backends can hand-shake their buckets, then each backend's
ingester sits in a 15 s "settle" window before it reports `/ready`.
During that window queries return `503: Ingester not ready: waiting for
15s after being ready` — that's an internal grace period to let other
ring members discover the node. Single-replica monolithic mode just
waits it out.

Verify by clicking through Grafana > Explore on each datasource:

- <http://localhost:13000/explore?left=%7B%22datasource%22:%22mimir%22%7D> — Mimir
- <http://localhost:13000/explore?left=%7B%22datasource%22:%22tempo%22%7D> — Tempo
- <http://localhost:13000/explore?left=%7B%22datasource%22:%22loki%22%7D> — Loki
- <http://localhost:13000/explore?left=%7B%22datasource%22:%22pyroscope%22%7D> — Pyroscope

Each should report "0 results" with no error banner. Phase 2 (instrumenting
the SvelteKit app) is what starts producing data.

## Bring-down

```bash
docker compose -f docker-compose.obs.yml down            # preserve data
docker compose -f docker-compose.obs.yml down -v         # wipe MinIO + Grafana
```

## Port map

Host ports are deliberately non-default to avoid clashing with the user's
`sentry-self-hosted` stack (port 9000), demo containers (port 8888), and
the SvelteKit dev server (port 3000). Container-internal ports are stock,
so any future bind-mount reference inside the docker network keeps using
e.g. `tempo:3200`, `loki:3100`, `mimir:9009`.

| Host port | Container port | Service        | Purpose                                |
|-----------|----------------|----------------|----------------------------------------|
| 13000     | 3000           | Grafana        | UI                                     |
| 4317      | 4317           | OTel Collector | OTLP gRPC ingest (app → collector)     |
| 4318      | 4318           | OTel Collector | OTLP HTTP ingest (app → collector)     |
| 12347     | 12347          | OTel Collector | Faro receiver (browser → collector)    |
| 18888     | 8888           | OTel Collector | Self-metrics (scraped by Mimir)        |
| 4040      | 4040           | Pyroscope      | Profile push endpoint                  |
| 3200      | 3200           | Tempo          | HTTP API (Grafana proxies it)          |
| 3100      | 3100           | Loki           | HTTP API (Grafana proxies it)          |
| 9009      | 9009           | Mimir          | HTTP API (Grafana proxies it)          |
| 9101      | 9001           | MinIO          | Console — bucket inspector             |
| 9100      | 9000           | MinIO          | S3 endpoint (mostly in-network use)    |
| 9094      | 9093           | Alertmanager   | Alert UI                               |

## Switching to real S3 on a VPS

Open `.env.obs`, comment out the MinIO block, uncomment the Hetzner block,
fill in the credentials, then:

```bash
docker compose -f docker-compose.obs.yml --env-file .env.obs up -d \
  --scale minio=0 --scale minio-init=0
```

The four backends will write to the Hetzner buckets transparently — no
config-file diff. Buckets must already exist in the Hetzner console, or
re-run `minio/provision.sh` against the new endpoint.

## Resource budget

The compose file caps each container's memory so the whole stack fits in
~3 GiB, leaving headroom for the SvelteKit app on a 4 GiB Hetzner CX22.
Adjust `deploy.resources.limits.memory` per service before deploying to
anything smaller.

## Where things live

```
observability/
├── docker-compose.obs.yml       # master compose — single bring-up command
├── .env.obs.example             # storage profile selector (MinIO / S3)
├── README.md                    # this file
│
├── tempo/tempo.yaml             # trace store, S3-backed
├── loki/loki.yaml               # log store, S3-backed
├── mimir/mimir.yaml             # metric store + alert rule loader
├── pyroscope/pyroscope.yaml     # profile store, S3-backed
│
├── otel-collector/config.yaml   # OTLP + Faro ingress, three pipelines
├── alertmanager/alertmanager.yaml
│
├── grafana/
│   ├── grafana.ini              # base UI config
│   ├── provisioning/
│   │   ├── datasources/datasources.yaml
│   │   └── dashboards/dashboards.yaml
│   └── dashboards/              # JSON dashboards committed in Phase 4
│
├── minio/provision.sh           # idempotent bucket creator
└── alerts/                      # Mimir-loaded *.yml rule groups, Phase 5
```

## Coexistence with Sentry

The existing `web/src/hooks.server.ts` keeps Sentry running. In Phase 2,
`web/src/instrument.ts` initialises OpenTelemetry with
`@sentry/opentelemetry`'s `skipOpenTelemetrySetup: true` flag, so Sentry
hands span generation to OTel and just gets a copy of every span via the
shared SDK adapter. Both backends see the same data. There's no
double-sampling because span sampling happens once, in OTel.

When the experiment ends, the merge-back decision is binary:

- **Keep both**: Sentry as the error funnel, LGTM as the deep-dive store.
  Cost on the VPS is one extra docker compose stack.
- **Drop OTel**: `git checkout main` and the experiment never touched main.
- **Replace Sentry**: rip out `@sentry/sveltekit`, route Sentry's
  alert-on-error logic through Mimir → Alertmanager. Bigger lift.

The comparison artefact in `obs-experiment-notes.md` (Phase 6) lays out
the trade-offs with measurements.
