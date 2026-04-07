import { describe, it, expect } from 'vitest';
import fs from 'node:fs/promises';
import path from 'node:path';
import os from 'node:os';
import { listPddlFiles, readFile, writeFile, savePddlToDir } from './files';

describe('listPddlFiles', () => {
	it('returns an array', async () => {
		const files = await listPddlFiles();
		expect(Array.isArray(files)).toBe(true);
	});

	it('each entry has name, path, dir fields', async () => {
		const files = await listPddlFiles();
		for (const f of files) {
			expect(f).toHaveProperty('name');
			expect(f).toHaveProperty('path');
			expect(f).toHaveProperty('dir');
			expect(f.name).toMatch(/\.pddl$/);
		}
	});
});

describe('readFile', () => {
	it('throws on path traversal', async () => {
		await expect(readFile('../../etc/passwd')).rejects.toThrow();
	});

	it('throws on nonexistent file', async () => {
		await expect(readFile('nonexistent_file_xyz.pddl')).rejects.toThrow();
	});
});

describe('writeFile', () => {
	it('rejects non-pddl files', async () => {
		await expect(writeFile('test.txt', 'content')).rejects.toThrow('Only .pddl');
	});
});

describe('savePddlToDir', () => {
	it('rejects invalid directory', async () => {
		await expect(savePddlToDir('InvalidDir', 'test.pddl', '')).rejects.toThrow(
			'Invalid directory'
		);
	});

	it('accepts valid directory', async () => {
		const result = await savePddlToDir('Basico', 'vitest_temp', '(define)');
		expect(result).toMatch(/Basico\/vitest_temp\.pddl$/);
		const fullPath = path.resolve('..', result);
		await fs.rm(fullPath, { force: true });
	});
});
