import type { PageServerLoad } from './$types';
import { listPddlFiles } from '$lib/server/files';

export const load: PageServerLoad = async () => {
	const files = await listPddlFiles();
	return { files };
};
