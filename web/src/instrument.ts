/**
 * OpenTelemetry NodeSDK boot file for the LGTM PoC.
 *
 * Imported as the very first line of `src/hooks.server.ts`, this file
 * starts the OTel SDK before SvelteKit loads any request handlers.
 * Auto-instrumentations (http, undici, fs, child_process, dns, net) hook
 * the corresponding Node primitives at module-load time, so the earlier
 * this runs the more coverage we get.
 *
 * Trade-off: a top-of-`hooks.server.ts` import isn't *quite* as early as
 * `node --import ./instrument.js`, since SvelteKit pulls a few internals
 * before our hooks file. The dev-time miss is small (kit-internal HTTP
 * keepalives, mostly); production builds should switch to the
 * `--import` flag — see Phase 6 of the PoC for the prod boot.
 *
 * Boot is gated on `OTEL_EXPORTER_OTLP_ENDPOINT` being set, so a
 * developer can still run `npm run dev` without bringing up the obs
 * stack. With the env var unset this module is a few cheap requires and
 * an early return — zero side effects on the SvelteKit runtime.
 */
import { NodeSDK } from '@opentelemetry/sdk-node';
import { resourceFromAttributes } from '@opentelemetry/resources';
import {
  ATTR_SERVICE_NAME,
  ATTR_SERVICE_NAMESPACE,
  ATTR_SERVICE_VERSION,
} from '@opentelemetry/semantic-conventions';
import { OTLPTraceExporter } from '@opentelemetry/exporter-trace-otlp-grpc';
import { OTLPMetricExporter } from '@opentelemetry/exporter-metrics-otlp-grpc';
import { OTLPLogExporter } from '@opentelemetry/exporter-logs-otlp-grpc';
import { BatchSpanProcessor } from '@opentelemetry/sdk-trace-base';
import { PeriodicExportingMetricReader } from '@opentelemetry/sdk-metrics';
import { BatchLogRecordProcessor } from '@opentelemetry/sdk-logs';
import { getNodeAutoInstrumentations } from '@opentelemetry/auto-instrumentations-node';

const endpoint = process.env.OTEL_EXPORTER_OTLP_ENDPOINT;

if (endpoint) {
  // The `deployment.environment.name` key replaced the older
  // `deployment.environment` in semconv ≥1.27. We use the new name
  // explicitly because it isn't yet exported from the stable subset of
  // `@opentelemetry/semantic-conventions`.
  const resource = resourceFromAttributes({
    [ATTR_SERVICE_NAME]: process.env.OTEL_SERVICE_NAME ?? 'planificacion-web',
    [ATTR_SERVICE_NAMESPACE]: 'planificacion',
    [ATTR_SERVICE_VERSION]: process.env.GIT_SHA ?? 'dev',
    'deployment.environment.name': process.env.NODE_ENV ?? 'development',
  });

  const sdk = new NodeSDK({
    resource,
    spanProcessors: [
      new BatchSpanProcessor(new OTLPTraceExporter({ url: endpoint })),
    ],
    metricReaders: [
      new PeriodicExportingMetricReader({
        exporter: new OTLPMetricExporter({ url: endpoint }),
        // 10s gives Mimir a steady cadence without overwhelming the dev
        // collector. Production can drop to 60s via env override.
        exportIntervalMillis: Number(
          process.env.OTEL_METRIC_EXPORT_INTERVAL ?? 10_000,
        ),
      }),
    ],
    logRecordProcessors: [
      new BatchLogRecordProcessor(new OTLPLogExporter({ url: endpoint })),
    ],
    // Sampler is left unset so the SDK reads `OTEL_TRACES_SAMPLER` /
    // `OTEL_TRACES_SAMPLER_ARG` from the environment — the values in
    // .env.obs default to parentbased_traceidratio @ 1.0 in dev.
    instrumentations: [getNodeAutoInstrumentations()],
  });

  sdk.start();

  // Graceful shutdown so the BatchSpanProcessor / BatchLogRecordProcessor
  // get to flush their queues. Without this, the last second of dev
  // traffic disappears every time vite restarts.
  for (const sig of ['SIGTERM', 'SIGINT'] as const) {
    process.once(sig, () => {
      sdk
        .shutdown()
        .catch((err: unknown) => {
          process.stderr.write(`OTel shutdown error: ${String(err)}\n`);
        })
        .finally(() => process.exit(0));
    });
  }
}
