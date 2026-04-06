import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import fs from 'node:fs/promises';
import path from 'node:path';

const execFileAsync = promisify(execFile);

const PROJECT_ROOT = path.resolve('..');
const TOOLS_DIR = path.resolve('tools');
const FF_BIN = path.join(TOOLS_DIR, 'metric-ff', 'ff');

export async function isPlannerInstalled(): Promise<boolean> {
	try {
		await fs.access(FF_BIN, fs.constants.X_OK);
		return true;
	} catch {
		return false;
	}
}

export interface PlannerResult {
	stdout: string;
	stderr: string;
	planFile: string | null;
}

function extractPlanFromOutput(stdout: string): string | null {
	const marker = 'ff: found legal plan as follows';
	const idx = stdout.toLowerCase().indexOf(marker.toLowerCase());
	if (idx === -1) return null;

	const after = stdout.slice(idx + marker.length);
	const lines = after.split('\n');
	const planLines: string[] = [];

	for (const line of lines) {
		const trimmed = line.trim();
		if (!trimmed) continue;
		const stepMatch = trimmed.match(/^step\s+(\d+):\s+(.+)/i);
		if (stepMatch) {
			planLines.push(`(${stepMatch[2].toLowerCase()})`);
			continue;
		}
		const contMatch = trimmed.match(/^(\d+):\s+(.+)/);
		if (contMatch) {
			planLines.push(`(${contMatch[2].toLowerCase()})`);
			continue;
		}
		if (trimmed.startsWith('time spent:') || trimmed.startsWith('plan cost:')) break;
	}

	return planLines.length > 0 ? planLines.join('\n') + '\n' : null;
}

export async function runPlanner(
	domainPath: string,
	problemPath: string
): Promise<PlannerResult> {
	const domainFull = path.join(PROJECT_ROOT, domainPath);
	const problemFull = path.join(PROJECT_ROOT, problemPath);

	for (const p of [domainFull, problemFull]) {
		const resolved = path.resolve(p);
		if (!resolved.startsWith(PROJECT_ROOT)) {
			throw new Error('Path traversal not allowed');
		}
	}

	const args = [
		'-s', '0',
		'-o', domainFull,
		'-f', problemFull
	];

	let stdout = '';
	let stderr = '';
	try {
		const result = await execFileAsync(FF_BIN, args, {
			timeout: 300000,
			cwd: TOOLS_DIR
		});
		stdout = result.stdout;
		stderr = result.stderr;
	} catch (err: unknown) {
		const e = err as { stdout?: string; stderr?: string; code?: number };
		stdout = e.stdout ?? '';
		stderr = e.stderr ?? '';
	}

	const planFile = extractPlanFromOutput(stdout);

	return { stdout, stderr, planFile };
}
