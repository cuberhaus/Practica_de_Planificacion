import type { PageServerLoad } from './$types';
import { listDomainProblemPairs } from '$lib/server/files';
import { isPlannerInstalled } from '$lib/server/planner';

export const load: PageServerLoad = async () => {
	const [pairs, plannerInstalled] = await Promise.all([
		listDomainProblemPairs(),
		isPlannerInstalled()
	]);
	return { pairs, plannerInstalled };
};
