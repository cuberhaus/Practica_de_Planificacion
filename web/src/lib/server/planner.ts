import { execFile } from 'node:child_process';
import { promisify } from 'node:util';
import fs from 'node:fs/promises';
import path from 'node:path';

const execFileAsync = promisify(execFile);

const PROJECT_ROOT = path.resolve('..');
const TOOLS_DIR = path.resolve('tools');
const FD_DIR = path.join(TOOLS_DIR, 'fast-downward');
const FD_SCRIPT = path.join(FD_DIR, 'fast-downward.py');

export async function isPlannerInstalled(): Promise<boolean> {
	try {
		await fs.access(FD_SCRIPT);
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
		FD_SCRIPT,
		'--alias',
		'lama-first',
		domainFull,
		problemFull
	];

	let stdout = '';
	let stderr = '';
	try {
		const result = await execFileAsync('python3', args, {
			timeout: 120000,
			cwd: TOOLS_DIR
		});
		stdout = result.stdout;
		stderr = result.stderr;
	} catch (err: unknown) {
		const e = err as { stdout?: string; stderr?: string; code?: number };
		stdout = e.stdout ?? '';
		stderr = e.stderr ?? '';
		// Fast Downward exits with various codes (e.g., 0 = solved, 12 = unsolvable)
		// We still want to return the output
	}

	let planFile: string | null = null;
	const planPath = path.join(TOOLS_DIR, 'sas_plan');
	try {
		await fs.access(planPath);
		planFile = await fs.readFile(planPath, 'utf-8');
		await fs.unlink(planPath);
	} catch {
		// no plan produced
	}

	// Also clean up Fast Downward temp file
	try {
		await fs.unlink(path.join(TOOLS_DIR, 'output.sas'));
	} catch { /* ignore */ }

	return { stdout, stderr, planFile };
}
