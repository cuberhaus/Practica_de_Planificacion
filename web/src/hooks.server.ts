/**
 * Server hooks — OTel-instrumented variant of the SvelteKit entry.
 *
 * The `instrument.js` import on the very first line MUST run before any
 * other module loads so the OTel auto-instrumentations have a chance to
 * hook `http`, `child_process`, etc. at require-time. Anything imported
 * above this line will execute uninstrumented.
 *
 * The HTTP auto-instrumentation creates the parent request span for us
 * automatically, so the `handle` chain is intentionally minimal — we
 * only need it for app-level error capture and structured logging.
 */
import './instrument.js';

import { performance } from 'node:perf_hooks';
import { trace, SpanStatusCode } from '@opentelemetry/api';
import type { Handle, HandleServerError } from '@sveltejs/kit';
import { logger } from '$lib/observability';

// Minimal access log: one Pino line per request, joined to the active
// trace via OTLP's automatic trace_id/span_id stamping. Cheap (a single
// performance.now() pair plus one structured emit) and gives us a
// service.name='planificacion-web' stream in Loki out of the box —
// without it, Pino would only emit on unhandled errors and the logs
// pipeline would look dead during a healthy steady state.
export const handle: Handle = async ({ event, resolve }) => {
  const start = performance.now();
  const response = await resolve(event);
  logger.info(
    {
      method: event.request.method,
      path: event.url.pathname,
      status: response.status,
      duration_ms: Math.round((performance.now() - start) * 100) / 100,
    },
    'http request',
  );
  return response;
};

export const handleError: HandleServerError = ({ error, event }) => {
  const span = trace.getActiveSpan();
  if (span) {
    span.recordException(error as Error);
    span.setStatus({
      code: SpanStatusCode.ERROR,
      message: error instanceof Error ? error.message : String(error),
    });
  }

  logger.error(
    {
      err: error,
      path: event.url.pathname,
      method: event.request.method,
    },
    'unhandled server error',
  );

  return {
    message: error instanceof Error ? error.message : String(error),
  };
};
