/**
 * Server hooks — Sentry-free baseline on the obs-experiment-lgtm branch.
 *
 * `main` ships a Sentry-instrumented version of this file; on this branch
 * we strip Sentry entirely so the LGTM PoC is a clean A/B against the
 * Sentry-on-main baseline. Phase 2 of the PoC will replace the JSON-line
 * `console.*` wrapper with Pino + pino-opentelemetry-transport, and add
 * an `instrument.ts` boot file that wires the OTel NodeSDK before any
 * other module loads.
 *
 * For now this commit is intentionally minimal: it keeps the JSON-line
 * console wrapper so the PersonalPortfolio log-relay still gets readable
 * stdout, and otherwise lets SvelteKit's defaults handle requests.
 */
import type { Handle, HandleServerError } from '@sveltejs/kit';

type LogLevel = 'trace' | 'info' | 'warn' | 'error';
const LEVEL_MAP: Record<string, LogLevel> = {
  log: 'info',
  info: 'info',
  warn: 'warn',
  error: 'error',
  debug: 'trace',
};

if (process.env.STRUCTURED_LOGS === '1') {
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

export const handle: Handle = async ({ event, resolve }) => resolve(event);

export const handleError: HandleServerError = ({ error }) => ({
  message: error instanceof Error ? error.message : String(error),
});
