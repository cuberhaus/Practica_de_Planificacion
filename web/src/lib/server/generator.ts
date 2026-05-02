import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import { performance } from 'node:perf_hooks';
import path from 'node:path';
import {
	withSpan,
	generatorDurationHistogram,
	generatorCallsCounter,
} from '$lib/observability';

const execFileAsync = promisify(execFile);

const GENERATOR_PATH = path.resolve('generator.py');

export interface GenerateParams {
	level: string;
	cities: number;
	minCities: number;
	flights: number;
	hotels: number;
	minDays?: number;
	maxDays?: number;
	minTotalDays?: number;
	minPrice?: number;
	maxPrice?: number;
	seed?: number;
}

export async function generatePddl(params: GenerateParams): Promise<string> {
	return withSpan(
		'generator.run',
		{
			'generator.binary': 'python3',
			'generator.script': 'generator.py',
			'generator.level': params.level,
			'generator.cities': params.cities,
			'generator.flights': params.flights,
			'generator.hotels': params.hotels,
		},
		async (span) => {
			const start = performance.now();
			let status: 'ok' | 'error' = 'ok';
			try {
				const args = [
					GENERATOR_PATH,
					'--level',
					params.level,
					'--cities',
					String(params.cities),
					'--min-cities',
					String(params.minCities),
					'--flights',
					String(params.flights),
					'--hotels',
					String(params.hotels)
				];

				if (params.minDays !== undefined) args.push('--min-days', String(params.minDays));
				if (params.maxDays !== undefined) args.push('--max-days', String(params.maxDays));
				if (params.minTotalDays !== undefined)
					args.push('--min-total-days', String(params.minTotalDays));
				if (params.minPrice !== undefined) args.push('--min-price', String(params.minPrice));
				if (params.maxPrice !== undefined) args.push('--max-price', String(params.maxPrice));
				if (params.seed !== undefined) {
					args.push('--seed', String(params.seed));
					span.setAttribute('generator.seed', params.seed);
				}

				const { stdout, stderr } = await execFileAsync('python3', args, { timeout: 10000 });

				if (stderr && stderr.trim()) {
					throw new Error(stderr.trim());
				}

				span.setAttributes({
					'generator.pddl_bytes': stdout.length,
					'generator.pddl_lines': stdout.split('\n').length,
				});

				return stdout;
			} catch (err) {
				status = 'error';
				throw err;
			} finally {
				const durationSeconds = (performance.now() - start) / 1000;
				// `level` joins the metric attributes so the dashboards can
				// break down generator latency by difficulty (easy / medium
				// / hard) — that's the breakdown the planner team cares
				// about most.
				const attrs = { status, level: params.level };
				generatorDurationHistogram.record(durationSeconds, attrs);
				generatorCallsCounter.add(1, attrs);
			}
		}
	);
}
