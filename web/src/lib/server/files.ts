import fs from 'node:fs/promises';
import path from 'node:path';

const PROJECT_ROOT = path.resolve('..');

const ALLOWED_DIRS = ['Basico', 'Extension_1', 'Extension_2', 'Extension_3', 'Extension_4', 'Extra_2'];

export interface FileEntry {
	name: string;
	path: string;
	dir: string;
}

function isPathSafe(filePath: string): boolean {
	const resolved = path.resolve(filePath);
	return resolved.startsWith(PROJECT_ROOT);
}

export async function listPddlFiles(): Promise<FileEntry[]> {
	const files: FileEntry[] = [];

	for (const dir of ALLOWED_DIRS) {
		const dirPath = path.join(PROJECT_ROOT, dir);
		try {
			const entries = await fs.readdir(dirPath);
			for (const entry of entries) {
				if (entry.endsWith('.pddl')) {
					files.push({
						name: entry,
						path: path.join(dir, entry),
						dir
					});
				}
			}
		} catch {
			// directory may not exist
		}
	}

	return files;
}

export async function readFile(relativePath: string): Promise<string> {
	const fullPath = path.join(PROJECT_ROOT, relativePath);
	if (!isPathSafe(fullPath)) throw new Error('Path traversal not allowed');
	return fs.readFile(fullPath, 'utf-8');
}

export async function writeFile(relativePath: string, content: string): Promise<void> {
	const fullPath = path.join(PROJECT_ROOT, relativePath);
	if (!isPathSafe(fullPath)) throw new Error('Path traversal not allowed');
	if (!relativePath.endsWith('.pddl')) throw new Error('Only .pddl files can be written');
	await fs.writeFile(fullPath, content, 'utf-8');
}

export async function savePddlToDir(
	dir: string,
	filename: string,
	content: string
): Promise<string> {
	if (!ALLOWED_DIRS.includes(dir)) throw new Error(`Invalid directory: ${dir}`);
	if (!filename.endsWith('.pddl')) filename += '.pddl';

	const relativePath = path.join(dir, filename);
	const fullPath = path.join(PROJECT_ROOT, relativePath);
	if (!isPathSafe(fullPath)) throw new Error('Path traversal not allowed');

	await fs.writeFile(fullPath, content, 'utf-8');
	return relativePath;
}

export interface DomainProblemPair {
	dir: string;
	domain: string;
	problems: string[];
}

export async function listDomainProblemPairs(): Promise<DomainProblemPair[]> {
	const pairs: DomainProblemPair[] = [];

	for (const dir of ALLOWED_DIRS) {
		const dirPath = path.join(PROJECT_ROOT, dir);
		try {
			const entries = await fs.readdir(dirPath);
			const domain = entries.find((e: string) => e.includes('domain') && e.endsWith('.pddl'));
			const problems = entries.filter(
				(e: string) => e.endsWith('.pddl') && !e.includes('domain')
			);
			if (domain && problems.length > 0) {
				pairs.push({ dir, domain, problems });
			}
		} catch {
			// skip
		}
	}

	return pairs;
}
