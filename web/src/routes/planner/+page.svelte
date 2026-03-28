<script lang="ts">
	import PddlEditor from '$lib/components/PddlEditor.svelte';
	import GraphPreview from '$lib/components/GraphPreview.svelte';
	import PlanSteps from '$lib/components/PlanSteps.svelte';
	import { parsePddlProblem, parsePlan, type PddlProblem, type PlanResult } from '$lib/pddl';

	let { data } = $props();

	let selectedDir = $state(data.pairs[0]?.dir ?? '');
	let selectedProblem = $state('');
	let running = $state(false);
	let error = $state('');

	let rawOutput = $state('');
	let planFileContent = $state('');
	let planResult = $state<PlanResult | null>(null);
	let parsedProblem = $state<PddlProblem | null>(null);
	let activeTab = $state<'steps' | 'raw' | 'graph'>('steps');

	let currentPair = $derived(data.pairs.find((p) => p.dir === selectedDir));
	let problems = $derived(currentPair?.problems ?? []);

	$effect(() => {
		if (currentPair && currentPair.problems.length > 0 && !currentPair.problems.includes(selectedProblem)) {
			selectedProblem = currentPair.problems[0];
		}
	});

	async function runPlanner() {
		if (!currentPair || !selectedProblem) return;
		running = true;
		error = '';
		rawOutput = '';
		planFileContent = '';
		planResult = null;
		parsedProblem = null;

		try {
			const domainPath = `${selectedDir}/${currentPair.domain}`;
			const problemPath = `${selectedDir}/${selectedProblem}`;

			// Load the problem file for graph visualization
			const fileRes = await fetch(`/api/files?path=${encodeURIComponent(problemPath)}`);
			if (fileRes.ok) {
				const fileData = await fileRes.json();
				parsedProblem = parsePddlProblem(fileData.content);
			}

			const res = await fetch('/api/plan', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ domain: domainPath, problem: problemPath })
			});

			const result = await res.json();

			if (!res.ok) {
				throw new Error(result.message || 'Planner failed');
			}

			rawOutput = result.stdout + (result.stderr ? '\n\nSTDERR:\n' + result.stderr : '');

			if (result.planFile) {
				planFileContent = result.planFile;
				planResult = parsePlan(result.planFile);
			}
		} catch (e) {
			error = e instanceof Error ? e.message : 'Unknown error';
		} finally {
			running = false;
		}
	}

	let route = $derived(planResult?.route ?? []);
</script>

<div class="mx-auto flex max-w-6xl flex-col gap-6">
	<h1 class="text-2xl font-bold text-text">
		<span class="text-primary-light">🗺️</span> Plan Runner
	</h1>

	{#if !data.plannerInstalled}
		<div class="rounded-xl border border-warning/50 bg-warning/10 p-6">
			<h2 class="mb-2 text-lg font-semibold text-warning">Planner Not Installed</h2>
			<p class="mb-4 text-sm text-text-muted">
				Fast Downward is not installed. To set it up, run the install script from the web directory:
			</p>
			<pre class="rounded-lg bg-surface p-4 text-sm text-text"><code>cd web && bash install-planner.sh</code></pre>
			<p class="mt-3 text-xs text-text-muted">
				This will clone and build Fast Downward into <code>web/tools/fast-downward/</code>.
				Requires CMake and a C++ compiler.
			</p>
		</div>
	{/if}

	<div class="grid grid-cols-[1fr_1fr] gap-6">
		<!-- Left: Config + Results -->
		<div class="flex flex-col gap-4">
			<div class="rounded-xl border border-border bg-surface p-5">
				<h2 class="mb-4 text-sm font-semibold uppercase tracking-wider text-text-muted">
					Configuration
				</h2>
				<div class="flex flex-col gap-3">
					<label class="flex flex-col gap-1">
						<span class="text-xs text-text-muted">Extension / Directory</span>
						<select
							bind:value={selectedDir}
							class="rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text focus:border-primary focus:outline-none"
						>
							{#each data.pairs as pair}
								<option value={pair.dir}>{pair.dir}</option>
							{/each}
						</select>
					</label>

					<label class="flex flex-col gap-1">
						<span class="text-xs text-text-muted">Problem File</span>
						<select
							bind:value={selectedProblem}
							class="rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text focus:border-primary focus:outline-none"
						>
							{#each problems as p}
								<option value={p}>{p}</option>
							{/each}
						</select>
					</label>

					{#if currentPair}
						<p class="text-xs text-text-muted">
							Domain: <span class="font-mono text-text">{currentPair.domain}</span>
						</p>
					{/if}

					<button
						onclick={runPlanner}
						disabled={running || !data.plannerInstalled || !currentPair}
						class="mt-2 w-full rounded-xl bg-primary px-4 py-3 text-sm font-semibold text-white transition-all hover:bg-primary-dark disabled:opacity-50"
					>
						{running ? 'Running Planner...' : 'Run Planner'}
					</button>

					{#if error}
						<p class="text-sm text-error">{error}</p>
					{/if}
				</div>
			</div>

			{#if planResult}
				<div class="rounded-xl border border-border bg-surface p-5">
					<div class="mb-4 flex gap-2">
						{#each (['steps', 'raw', 'graph'] as const) as tab}
							<button
								onclick={() => (activeTab = tab)}
								class="rounded-lg px-3 py-1.5 text-xs font-medium transition-colors
									{activeTab === tab
									? 'bg-primary/15 text-primary-light'
									: 'text-text-muted hover:text-text'}"
							>
								{tab === 'steps' ? 'Plan Steps' : tab === 'raw' ? 'Raw Output' : 'Graph'}
							</button>
						{/each}
					</div>

					{#if activeTab === 'steps'}
						<PlanSteps plan={planResult} />
					{:else if activeTab === 'raw'}
						<PddlEditor value={rawOutput} readonly />
					{:else if activeTab === 'graph' && parsedProblem}
						<GraphPreview problem={parsedProblem} highlightRoute={route} />
					{/if}
				</div>
			{:else if rawOutput}
				<div class="rounded-xl border border-border bg-surface p-5">
					<h2 class="mb-3 text-sm font-semibold uppercase tracking-wider text-text-muted">
						Planner Output
					</h2>
					<PddlEditor value={rawOutput} readonly />
				</div>
			{/if}
		</div>

		<!-- Right: Graph -->
		<div class="flex flex-col gap-4">
			{#if parsedProblem}
				<div class="rounded-xl border border-border bg-surface p-5">
					<h2 class="mb-3 text-sm font-semibold uppercase tracking-wider text-text-muted">
						Network Graph
						{#if route.length > 0}
							<span class="ml-2 text-xs font-normal text-success">
								Route: {route.join(' → ')}
							</span>
						{/if}
					</h2>
					<GraphPreview problem={parsedProblem} highlightRoute={route} />
					<div class="mt-3 flex flex-wrap gap-4 text-xs text-text-muted">
						<span>
							<span class="mr-1 inline-block h-2.5 w-2.5 rounded-full bg-primary"></span>
							Cities
						</span>
						<span>
							<span class="mr-1 inline-block h-2.5 w-2.5 rounded-full bg-warning"></span>
							Hotels
						</span>
						{#if route.length > 0}
							<span>
								<span class="mr-1 inline-block h-2.5 w-2.5 rounded-full bg-success"></span>
								Route
							</span>
						{/if}
					</div>
				</div>

				{#if planResult && planResult.steps.length > 0}
					<div class="rounded-xl border border-border bg-surface p-5">
						<h2 class="mb-3 text-sm font-semibold uppercase tracking-wider text-text-muted">
							Trip Summary
						</h2>
						<div class="grid grid-cols-2 gap-3">
							<div class="rounded-lg bg-surface-light p-3">
								<p class="text-xs text-text-muted">Cities Visited</p>
								<p class="text-xl font-bold text-primary-light">{route.length}</p>
							</div>
							<div class="rounded-lg bg-surface-light p-3">
								<p class="text-xs text-text-muted">Plan Steps</p>
								<p class="text-xl font-bold text-text">{planResult.steps.length}</p>
							</div>
							{#if planResult.totalCost !== null}
								<div class="col-span-2 rounded-lg bg-surface-light p-3">
									<p class="text-xs text-text-muted">Total Cost</p>
									<p class="text-xl font-bold text-success">{planResult.totalCost}</p>
								</div>
							{/if}
						</div>
					</div>
				{/if}
			{:else}
				<div class="flex flex-1 items-center justify-center rounded-xl border border-dashed border-border bg-surface p-12">
					<p class="text-center text-text-muted">
						Select a domain and problem file, then click <strong>Run Planner</strong> to see the plan and graph visualization.
					</p>
				</div>
			{/if}
		</div>
	</div>
</div>
