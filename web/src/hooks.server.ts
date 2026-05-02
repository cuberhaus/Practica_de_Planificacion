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

import { trace, SpanStatusCode } from '@opentelemetry/api';
import type { Handle, HandleServerError } from '@sveltejs/kit';
import { logger } from '$lib/observability';

export const handle: Handle = async ({ event, resolve }) => resolve(event);

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
