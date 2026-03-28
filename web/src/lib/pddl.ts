/**
 * Lightweight PDDL parser for extracting graph-relevant data from problem files.
 * Not a full PDDL parser -- focuses on objects, predicates, and numeric fluents
 * used in the agencia_viaje domain.
 */

export interface PddlObjects {
	cities: string[];
	flights: string[];
	hotels: string[];
	days: string[];
}

export interface FlightEdge {
	flight: string;
	from: string;
	to: string;
}

export interface HotelLocation {
	hotel: string;
	city: string;
}

export interface NumericFluent {
	name: string;
	args: string[];
	value: number;
}

export interface PddlProblem {
	objects: PddlObjects;
	flights: FlightEdge[];
	hotels: HotelLocation[];
	fluents: NumericFluent[];
	currentCity: string | null;
	visitedCities: string[];
	goals: string[];
	metric: string | null;
}

export interface PlanStep {
	index: number;
	action: string;
	params: string[];
	cost: number | null;
}

export interface PlanResult {
	steps: PlanStep[];
	totalCost: number | null;
	route: string[];
}

function extractSection(pddl: string, tag: string): string | null {
	const tagLower = tag.toLowerCase();
	const lower = pddl.toLowerCase();
	const idx = lower.indexOf(`(:${tagLower}`);
	if (idx === -1) return null;

	let depth = 0;
	let start = idx;
	for (let i = idx; i < pddl.length; i++) {
		if (pddl[i] === '(') depth++;
		else if (pddl[i] === ')') {
			depth--;
			if (depth === 0) return pddl.slice(start, i + 1);
		}
	}
	return null;
}

function parseObjects(pddl: string): PddlObjects {
	const result: PddlObjects = { cities: [], flights: [], hotels: [], days: [] };
	const section = extractSection(pddl, 'objects');
	if (!section) return result;

	const inner = section.replace(/^\(:objects/i, '').replace(/\)$/, '').trim();
	const groups = inner.split(/\s+-\s+/);

	for (let i = 0; i < groups.length - 1; i++) {
		const names = groups[i].trim().split(/\s+/);
		const typeRaw = groups[i + 1].trim().split(/\s+/)[0].toLowerCase();

		const cleanNames = names.filter((n) => n.length > 0 && !n.startsWith('-'));

		if (typeRaw === 'ciudad') result.cities.push(...cleanNames);
		else if (typeRaw === 'vuelo') result.flights.push(...cleanNames);
		else if (typeRaw === 'hotel') result.hotels.push(...cleanNames);
		else if (typeRaw === 'dias_por_ciudad') result.days.push(...cleanNames);
	}
	return result;
}

function parseInit(pddl: string): {
	flights: FlightEdge[];
	hotels: HotelLocation[];
	fluents: NumericFluent[];
	currentCity: string | null;
	visitedCities: string[];
} {
	const flights: FlightEdge[] = [];
	const hotels: HotelLocation[] = [];
	const fluents: NumericFluent[] = [];
	let currentCity: string | null = null;
	const visitedCities: string[] = [];

	const section = extractSection(pddl, 'init');
	if (!section) return { flights, hotels, fluents, currentCity, visitedCities };

	const vaARegex = /\(va_a\s+(\S+)\s+(\S+)\s+(\S+)\s*\)/gi;
	let m: RegExpExecArray | null;
	while ((m = vaARegex.exec(section)) !== null) {
		flights.push({ flight: m[1], from: m[2], to: m[3] });
	}

	const estaEnRegex = /\(esta_en\s+(\S+)\s+(\S+)\s*\)/gi;
	while ((m = estaEnRegex.exec(section)) !== null) {
		hotels.push({ hotel: m[1], city: m[2] });
	}

	const currentRegex = /\(current_ciudad\s+(\S+)\s*\)/i;
	const cm = currentRegex.exec(section);
	if (cm) currentCity = cm[1];

	const visitedRegex = /\(ciudad_visitada\s+(\S+)\s*\)/gi;
	while ((m = visitedRegex.exec(section)) !== null) {
		visitedCities.push(m[1]);
	}

	const fluentRegex = /\(=\s+\((\S+?)(?:\s+(\S+))?\)\s+(-?\d+(?:\.\d+)?)\s*\)/gi;
	while ((m = fluentRegex.exec(section)) !== null) {
		fluents.push({
			name: m[1],
			args: m[2] ? [m[2]] : [],
			value: parseFloat(m[3])
		});
	}

	return { flights, hotels, fluents, currentCity, visitedCities };
}

function parseGoal(pddl: string): string[] {
	const section = extractSection(pddl, 'goal');
	if (!section) return [];
	const condRegex = /\((?:<=|>=|=|>|<)\s+\([^)]+\)\s+\([^)]+\)\)/g;
	const goals: string[] = [];
	let m: RegExpExecArray | null;
	while ((m = condRegex.exec(section)) !== null) {
		goals.push(m[0]);
	}
	return goals;
}

function parseMetric(pddl: string): string | null {
	const section = extractSection(pddl, 'metric');
	return section;
}

export function parsePddlProblem(pddl: string): PddlProblem {
	const objects = parseObjects(pddl);
	const init = parseInit(pddl);
	const goals = parseGoal(pddl);
	const metric = parseMetric(pddl);

	return {
		objects,
		flights: init.flights,
		hotels: init.hotels,
		fluents: init.fluents,
		currentCity: init.currentCity,
		visitedCities: init.visitedCities,
		goals,
		metric
	};
}

/**
 * Parse Fast Downward / Metric-FF plan output.
 * Handles formats like:
 *   (anadir_ciudad v1 c1 c2 h1 dias2) ; cost = 1
 * or numbered:
 *   0: (anadir_ciudad v1 c1 c2 h1 dias2)
 */
export function parsePlan(output: string): PlanResult {
	const steps: PlanStep[] = [];
	const route: string[] = [];

	const lines = output.split('\n');
	let idx = 0;

	for (const line of lines) {
		const trimmed = line.trim();
		if (!trimmed || trimmed.startsWith(';') || trimmed.startsWith('#')) continue;

		const stepMatch = trimmed.match(
			/^(?:(\d+):\s*)?\((\S+)((?:\s+\S+)*)\)\s*(?:;\s*cost\s*=\s*(\d+))?/i
		);
		if (stepMatch) {
			const action = stepMatch[2];
			const params = stepMatch[3].trim().split(/\s+/).filter(Boolean);
			const cost = stepMatch[4] ? parseInt(stepMatch[4]) : null;

			steps.push({ index: idx++, action, params, cost });

			if (action.toLowerCase() === 'anadir_ciudad' && params.length >= 3) {
				if (route.length === 0) route.push(params[1]);
				route.push(params[2]);
			}
		}
	}

	const costLine = lines.find((l) => /plan cost/i.test(l));
	let totalCost: number | null = null;
	if (costLine) {
		const cm = costLine.match(/(\d+(?:\.\d+)?)/);
		if (cm) totalCost = parseFloat(cm[1]);
	}

	return { steps, totalCost, route };
}
