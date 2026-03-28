import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import path from 'node:path';

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
	if (params.seed !== undefined) args.push('--seed', String(params.seed));

	const { stdout, stderr } = await execFileAsync('python3', args, { timeout: 10000 });
	if (stderr && stderr.trim()) {
		throw new Error(stderr.trim());
	}
	return stdout;
}
