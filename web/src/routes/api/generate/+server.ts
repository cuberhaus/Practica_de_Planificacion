import { json, error } from '@sveltejs/kit';
import type { RequestHandler } from './$types';
import { generatePddl } from '$lib/server/generator';

export const POST: RequestHandler = async ({ request }) => {
	const body = await request.json();

	const required = ['level', 'cities', 'minCities', 'flights', 'hotels'];
	for (const key of required) {
		if (body[key] === undefined) {
			error(400, `Missing required field: ${key}`);
		}
	}

	if (body.flights < body.cities) {
		error(400, 'Flights must be >= cities');
	}
	if (body.hotels < body.cities) {
		error(400, 'Hotels must be >= cities');
	}

	try {
		const pddl = await generatePddl(body);
		return json({ pddl });
	} catch (err) {
		const message = err instanceof Error ? err.message : 'Generation failed';
		error(500, message);
	}
};
