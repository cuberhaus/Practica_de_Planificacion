<script lang="ts">
	import { onMount } from 'svelte';
	import type { PddlProblem } from '$lib/pddl';

	interface Props {
		problem: PddlProblem | null;
		highlightRoute?: string[];
	}

	let { problem, highlightRoute = [] }: Props = $props();

	let container: HTMLDivElement;
	let network: unknown = null;

	const CITY_COLOR = '#6366f1';
	const CITY_HIGHLIGHT = '#818cf8';
	const ROUTE_COLOR = '#22c55e';
	const EDGE_COLOR = '#555580';
	const HOTEL_COLOR = '#f59e0b';

	function buildGraph(prob: PddlProblem, route: string[]) {
		const routeSet = new Set<string>();
		for (let i = 0; i < route.length - 1; i++) {
			routeSet.add(`${route[i]}->${route[i + 1]}`);
		}
		const routeCities = new Set(route);

		const nodes: Array<Record<string, unknown>> = [];
		const edges: Array<Record<string, unknown>> = [];
		const addedCities = new Set<string>();

		for (const city of prob.objects.cities) {
			const isOnRoute = routeCities.has(city);
			const isCurrent = city === prob.currentCity;
			nodes.push({
				id: city,
				label: city,
				color: {
					background: isOnRoute ? ROUTE_COLOR : CITY_COLOR,
					border: isCurrent ? '#fff' : isOnRoute ? ROUTE_COLOR : CITY_HIGHLIGHT,
					highlight: { background: CITY_HIGHLIGHT, border: '#fff' }
				},
				borderWidth: isCurrent ? 3 : 1,
				shape: 'dot',
				size: isCurrent ? 25 : 18,
				font: { color: '#e0e0f0', size: 12 }
			});
			addedCities.add(city);
		}

		const hotelsByCity = new Map<string, string[]>();
		for (const h of prob.hotels) {
			const list = hotelsByCity.get(h.city) || [];
			list.push(h.hotel);
			hotelsByCity.set(h.city, list);
		}

		for (const [city, hotels] of hotelsByCity) {
			if (!addedCities.has(city)) continue;
			const hotelId = `hotels_${city}`;
			nodes.push({
				id: hotelId,
				label: hotels.join(', '),
				color: { background: HOTEL_COLOR, border: HOTEL_COLOR },
				shape: 'diamond',
				size: 10,
				font: { color: '#e0e0f0', size: 10 }
			});
			edges.push({
				from: city,
				to: hotelId,
				dashes: true,
				color: { color: HOTEL_COLOR, opacity: 0.5 },
				width: 1,
				arrows: ''
			});
		}

		for (const flight of prob.flights) {
			if (!addedCities.has(flight.from) || !addedCities.has(flight.to)) continue;
			const isRouteEdge = routeSet.has(`${flight.from}->${flight.to}`);
			const priceFluent = prob.fluents.find(
				(f) => f.name === 'precio_vuelo' && f.args[0] === flight.flight
			);
			let label = flight.flight;
			if (priceFluent) label += ` ($${priceFluent.value})`;

			edges.push({
				from: flight.from,
				to: flight.to,
				label,
				color: {
					color: isRouteEdge ? ROUTE_COLOR : EDGE_COLOR,
					highlight: CITY_HIGHLIGHT
				},
				width: isRouteEdge ? 3 : 1,
				arrows: { to: { enabled: true, scaleFactor: 0.6 } },
				font: { color: '#a0a0c0', size: 9, strokeWidth: 0 }
			});
		}

		return { nodes, edges };
	}

	async function render() {
		if (!container || !problem) return;
		if (problem.objects.cities.length === 0) return;

		const { Network } = await import('vis-network');
		const { DataSet } = await import('vis-data');
		const { nodes, edges } = buildGraph(problem, highlightRoute);

		const data = {
			nodes: new DataSet(nodes),
			edges: new DataSet(edges)
		};

		const options = {
			physics: {
				solver: 'forceAtlas2Based' as const,
				forceAtlas2Based: { gravitationalConstant: -80, springLength: 150 }
			},
			interaction: { hover: true, zoomView: true, dragView: true },
			layout: { improvedLayout: true }
		};

		if (network) {
			(network as { destroy: () => void }).destroy();
		}
		network = new Network(container, data, options);
	}

	onMount(() => {
		render();
		return () => {
			if (network) (network as { destroy: () => void }).destroy();
		};
	});

	$effect(() => {
		if (problem) render();
	});
</script>

<div
	bind:this={container}
	class="h-[400px] w-full rounded-lg border border-border bg-surface"
></div>
