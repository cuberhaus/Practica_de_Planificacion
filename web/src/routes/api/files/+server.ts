import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { readFile, writeFile, savePddlToDir, listPddlFiles } from '$lib/server/files';

export const GET: RequestHandler = async ({ url }) => {
	const filePath = url.searchParams.get('path');

	if (filePath) {
		try {
			const content = await readFile(filePath);
			return json({ content });
		} catch (err) {
			const message = err instanceof Error ? err.message : 'Read failed';
			error(404, message);
		}
	}

	const files = await listPddlFiles();
	return json({ files });
};

export const PUT: RequestHandler = async ({ request }) => {
	const body = await request.json();

	if (body.path && body.content !== undefined) {
		try {
			await writeFile(body.path, body.content);
			return json({ ok: true });
		} catch (err) {
			const message = err instanceof Error ? err.message : 'Write failed';
			error(400, message);
		}
	}

	if (body.dir && body.filename && body.content !== undefined) {
		try {
			const savedPath = await savePddlToDir(body.dir, body.filename, body.content);
			return json({ ok: true, path: savedPath });
		} catch (err) {
			const message = err instanceof Error ? err.message : 'Save failed';
			error(400, message);
		}
	}

	error(400, 'Provide either { path, content } or { dir, filename, content }');
};
