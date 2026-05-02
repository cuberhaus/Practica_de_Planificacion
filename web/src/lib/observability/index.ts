/**
 * Observability facade for the SvelteKit app.
 *
 * The rest of the app imports from `$lib/observability` rather than
 * touching `@opentelemetry/api` directly — keeps the OTel surface in
 * one place so future swap-outs (e.g. moving to Sentry on this branch
 * too, or adopting Grafana Alloy for a different ingest model) don't
 * have to touch every hot path.
 *
 * Exports:
 * - `tracer` / `meter`        → OTel scope handles for the planificacion app
 * - `logger`                  → Pino logger that ships logs over OTLP when
 *                               `OTEL_EXPORTER_OTLP_ENDPOINT` is set, plain
 *                               JSON to stdout otherwise
 * - `withSpan`                → boilerplate-free async-span helper
 * - `plannerDurationHistogram`, `plannerCallsCounter`,
 *   `generatorDurationHistogram`, `generatorCallsCounter`
 *                             → RED-style meters used by the hot paths
 */
import {
  metrics,
  trace,
  SpanStatusCode,
  type Attributes,
  type Span,
} from '@opentelemetry/api';
import pino, { type LoggerOptions } from 'pino';

const SCOPE = 'planificacion';
const SCOPE_VERSION = process.env.GIT_SHA ?? 'dev';

export const tracer = trace.getTracer(SCOPE, SCOPE_VERSION);
export const meter = metrics.getMeter(SCOPE, SCOPE_VERSION);

// ── RED meters ────────────────────────────────────────────────────────
//
// Histogram + counter pairs for the two hot paths the planificacion
// app actually cares about. The HTTP `request_duration` histogram is
// emitted automatically by the http auto-instrumentation, so we don't
// re-emit a generic version of it here.
//
// Naming: dot-separated as per OTel convention; the OTel→Prometheus
// translation in the Mimir endpoint converts `.` → `_` and may append
// `_seconds` for histograms with `unit: 's'`. When wiring dashboards in
// Phase 4 we'll lock the exact PromQL name.

export const plannerDurationHistogram = meter.createHistogram(
  'planificacion.planner.duration',
  {
    unit: 's',
    description: 'Wall-clock duration of metric-ff planner invocations.',
  },
);

export const plannerCallsCounter = meter.createCounter(
  'planificacion.planner.calls',
  {
    description: 'Total metric-ff planner invocations, by outcome.',
  },
);

export const generatorDurationHistogram = meter.createHistogram(
  'planificacion.generator.duration',
  {
    unit: 's',
    description: 'Wall-clock duration of PDDL generator invocations.',
  },
);

export const generatorCallsCounter = meter.createCounter(
  'planificacion.generator.calls',
  {
    description: 'Total PDDL generator invocations, by outcome and level.',
  },
);

// ── Logger ────────────────────────────────────────────────────────────
//
// Pino is the structured logger; when OTLP is enabled, the `pino-
// opentelemetry-transport` worker forwards every log record to the
// configured endpoint as an OTel log signal (joined to the active span
// via trace_id/span_id automatically). When OTLP is disabled, Pino
// falls back to plain JSON-on-stdout — same shape the PersonalPortfolio
// log-relay used to consume.
//
// We deliberately don't hijack `console.*` here: any code that needs
// structured logging should `import { logger } from '$lib/observability'`
// and call `logger.info / .warn / .error` directly. The previous
// console-wrapper hack lives only in legacy code paths and gets cleaned
// up incrementally.

const logTransport = process.env.OTEL_EXPORTER_OTLP_ENDPOINT
  ? {
      target: 'pino-opentelemetry-transport',
      options: {
        loggerName: SCOPE,
        serviceVersion: SCOPE_VERSION,
        resourceAttributes: {
          'service.name':
            process.env.OTEL_SERVICE_NAME ?? 'planificacion-web',
          'service.namespace': 'planificacion',
        },
      },
    }
  : undefined;

const loggerOptions: LoggerOptions = {
  level: process.env.LOG_LEVEL ?? 'info',
  base: { ns: SCOPE },
  ...(logTransport ? { transport: logTransport } : {}),
};

export const logger = pino(loggerOptions);

// ── withSpan ──────────────────────────────────────────────────────────
//
// Wraps an async function in an active span and handles the
// status / exception / end boilerplate. Re-throws on failure so the
// caller's error handling is unchanged.
//
// Example:
//
//     await withSpan('planner.run', { 'planner.binary': 'metric-ff' },
//       async (span) => {
//         span.setAttribute('planner.found_plan', true);
//         return await runFastDownward(...);
//       });

export async function withSpan<T>(
  name: string,
  attributes: Attributes,
  fn: (span: Span) => Promise<T>,
): Promise<T> {
  return tracer.startActiveSpan(name, { attributes }, async (span) => {
    try {
      const result = await fn(span);
      span.setStatus({ code: SpanStatusCode.OK });
      return result;
    } catch (err) {
      span.recordException(err as Error);
      span.setStatus({
        code: SpanStatusCode.ERROR,
        message: err instanceof Error ? err.message : String(err),
      });
      throw err;
    } finally {
      span.end();
    }
  });
}
