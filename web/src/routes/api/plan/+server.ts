import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { runPlanner, isPlannerInstalled } from '$lib/server/planner';

export const GET: RequestHandler = async () => {
	const installed = await isPlannerInstalled();
	return json({ installed });
};

export const POST: RequestHandler = async ({ request }) => {
	const installed = await isPlannerInstalled();
	if (!installed) {
		error(503, 'Fast Downward planner is not installed. See the Planner tab for setup instructions.');
	}

	const body = await request.json();
	if (!body.domain || !body.problem) {
		error(400, 'Missing domain or problem path');
	}

	try {
		const result = await runPlanner(body.domain, body.problem);
		return json(result);
	} catch (err) {
		const message = err instanceof Error ? err.message : 'Planner failed';
		error(500, message);
	}
};
