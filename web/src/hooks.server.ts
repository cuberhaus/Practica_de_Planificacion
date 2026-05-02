/**
 * Phase 14 (Option A) — Sentry SDK + JSON-line stdout for the SvelteKit
 * planificacion backend. The DSN is empty by default so the SDK is a
 * no-op until you set it via PersonalPortfolio/.env.shared.
 *
 * The `service` tag distinguishes this backend from other demos in the
 * shared Sentry project. The `console.*` wrapper emits one JSON object
 * per line so the PersonalPortfolio log-relay can forward backend logs
 * verbatim into the in-page debug overlay.
 */
import * as Sentry from '@sentry/sveltekit';
import type { Handle, HandleServerError } from '@sveltejs/kit';

const dsn = process.env.SENTRY_DSN ?? '';

if (dsn) {
  Sentry.init({
    dsn,
    environment: process.env.SENTRY_ENVIRONMENT ?? 'local-dev',
    release: process.env.SENTRY_RELEASE ?? 'local-dev',
    tracesSampleRate: Number(process.env.SENTRY_TRACES_SAMPLE_RATE ?? '1.0'),
    sendDefaultPii: false,
  });
  Sentry.setTag('service', 'planificacion');
}

type LogLevel = 'trace' | 'info' | 'warn' | 'error';
const LEVEL_MAP: Record<string, LogLevel> = {
  log: 'info',
  info: 'info',
  warn: 'warn',
  error: 'error',
  debug: 'trace',
};

if (process.env.SENTRY_DSN || process.env.STRUCTURED_LOGS === '1') {
  for (const method of Object.keys(LEVEL_MAP)) {
    const orig = (console as unknown as Record<string, (...args: unknown[]) => void>)[method];
    (console as unknown as Record<string, (...args: unknown[]) => void>)[method] = (
      ...args: unknown[]
    ) => {
      try {
        const line = JSON.stringify({
          level: LEVEL_MAP[method],
          ns: 'planificacion',
          msg: args.map((a) => (typeof a === 'string' ? a : JSON.stringify(a))).join(' '),
          ts: Date.now(),
        });
        process.stdout.write(line + '\n');
      } catch {
        orig.apply(console, args);
      }
    };
  }
}

export const handle: Handle = dsn
  ? Sentry.sentryHandle()
  : (async ({ event, resolve }) => resolve(event));

export const handleError: HandleServerError = dsn
  ? Sentry.handleErrorWithSentry()
  : (({ error }) => ({ message: error instanceof Error ? error.message : String(error) }));
