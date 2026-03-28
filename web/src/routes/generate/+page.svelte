<script lang="ts">
	import PddlEditor from '$lib/components/PddlEditor.svelte';
	import GraphPreview from '$lib/components/GraphPreview.svelte';
	import { parsePddlProblem, type PddlProblem } from '$lib/pddl';

	const LEVELS = [
		{ value: 'basico', label: 'Basico', desc: 'Cities + flights' },
		{ value: 'ext1', label: 'Extension 1', desc: '+ Days per city' },
		{ value: 'ext2', label: 'Extension 2', desc: '+ City interest' },
		{ value: 'ext3', label: 'Extension 3', desc: '+ Pricing' },
		{ value: 'ext4', label: 'Extension 4', desc: 'All combined' }
	];

	let level = $state('basico');
	let cities = $state(5);
	let minCities = $state(3);
	let flights = $state(6);
	let hotels = $state(5);
	let minDays = $state(1);
	let maxDays = $state(3);
	let minTotalDays = $state(5);
	let minPrice = $state(100);
	let maxPrice = $state(500);
	let seed = $state<number | undefined>(undefined);

	let pddlOutput = $state('');
	let parsedProblem = $state<PddlProblem | null>(null);
	let generating = $state(false);
	let error = $state('');
	let saveDir = $state('Basico');
	let saveFilename = $state('generated_problem');
	let saveMsg = $state('');

	let hasDays = $derived(['ext1', 'ext2', 'ext3', 'ext4'].includes(level));
	let hasPrice = $derived(['ext3', 'ext4'].includes(level));

	function dirForLevel(lvl: string): string {
		const map: Record<string, string> = {
			basico: 'Basico',
			ext1: 'Extension_1',
			ext2: 'Extension_2',
			ext3: 'Extension_3',
			ext4: 'Extension_4'
		};
		return map[lvl] ?? 'Basico';
	}

	$effect(() => {
		saveDir = dirForLevel(level);
	});

	async function generate() {
		generating = true;
		error = '';
		try {
			const body: Record<string, unknown> = {
				level,
				cities,
				minCities,
				flights,
				hotels
			};
			if (hasDays) {
				body.minDays = minDays;
				body.maxDays = maxDays;
				body.minTotalDays = minTotalDays;
			}
			if (hasPrice) {
				body.minPrice = minPrice;
				body.maxPrice = maxPrice;
			}
			if (seed !== undefined) body.seed = seed;

			const res = await fetch('/api/generate', {
				method: 'POST',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify(body)
			});
			if (!res.ok) {
				const data = await res.json();
				throw new Error(data.message || 'Generation failed');
			}
			const data = await res.json();
			pddlOutput = data.pddl;
			parsedProblem = parsePddlProblem(data.pddl);
		} catch (e) {
			error = e instanceof Error ? e.message : 'Unknown error';
		} finally {
			generating = false;
		}
	}

	async function saveToFile() {
		saveMsg = '';
		try {
			const res = await fetch('/api/files', {
				method: 'PUT',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({
					dir: saveDir,
					filename: saveFilename,
					content: pddlOutput
				})
			});
			if (!res.ok) throw new Error('Save failed');
			const data = await res.json();
			saveMsg = `Saved to ${data.path}`;
		} catch {
			saveMsg = 'Failed to save file';
		}
	}
</script>

<div class="mx-auto flex max-w-6xl flex-col gap-6">
	<h1 class="text-2xl font-bold text-text">
		<span class="text-primary-light">⚡</span> Problem Generator
	</h1>

	<div class="grid grid-cols-[1fr_1fr] gap-6">
		<!-- Left: Form -->
		<div class="flex flex-col gap-4">
			<div class="rounded-xl border border-border bg-surface p-5">
				<h2 class="mb-4 text-sm font-semibold uppercase tracking-wider text-text-muted">
					Extension Level
				</h2>
				<div class="grid grid-cols-5 gap-2">
					{#each LEVELS as lvl}
						<button
							onclick={() => (level = lvl.value)}
							class="rounded-lg border px-2 py-2 text-center text-xs font-medium transition-all
								{level === lvl.value
								? 'border-primary bg-primary/15 text-primary-light'
								: 'border-border text-text-muted hover:border-primary/30 hover:text-text'}"
						>
							<p class="font-semibold">{lvl.label}</p>
							<p class="mt-0.5 text-[10px] opacity-70">{lvl.desc}</p>
						</button>
					{/each}
				</div>
			</div>

			<div class="rounded-xl border border-border bg-surface p-5">
				<h2 class="mb-4 text-sm font-semibold uppercase tracking-wider text-text-muted">
					Parameters
				</h2>
				<div class="grid grid-cols-2 gap-3">
					<label class="flex flex-col gap-1">
						<span class="text-xs text-text-muted">Cities</span>
						<input
							type="number"
							min="1"
							bind:value={cities}
							class="rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text focus:border-primary focus:outline-none"
						/>
					</label>
					<label class="flex flex-col gap-1">
						<span class="text-xs text-text-muted">Min cities to visit</span>
						<input
							type="number"
							min="1"
							bind:value={minCities}
							class="rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text focus:border-primary focus:outline-none"
						/>
					</label>
					<label class="flex flex-col gap-1">
						<span class="text-xs text-text-muted">Flights (≥ cities)</span>
						<input
							type="number"
							min="1"
							bind:value={flights}
							class="rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text focus:border-primary focus:outline-none"
						/>
					</label>
					<label class="flex flex-col gap-1">
						<span class="text-xs text-text-muted">Hotels (≥ cities)</span>
						<input
							type="number"
							min="1"
							bind:value={hotels}
							class="rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text focus:border-primary focus:outline-none"
						/>
					</label>

					{#if hasDays}
						<label class="flex flex-col gap-1">
							<span class="text-xs text-text-muted">Min days/city</span>
							<input
								type="number"
								min="1"
								bind:value={minDays}
								class="rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text focus:border-primary focus:outline-none"
							/>
						</label>
						<label class="flex flex-col gap-1">
							<span class="text-xs text-text-muted">Max days/city</span>
							<input
								type="number"
								min="1"
								bind:value={maxDays}
								class="rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text focus:border-primary focus:outline-none"
							/>
						</label>
						<label class="col-span-2 flex flex-col gap-1">
							<span class="text-xs text-text-muted">Min total trip days</span>
							<input
								type="number"
								min="1"
								bind:value={minTotalDays}
								class="rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text focus:border-primary focus:outline-none"
							/>
						</label>
					{/if}

					{#if hasPrice}
						<label class="flex flex-col gap-1">
							<span class="text-xs text-text-muted">Min price</span>
							<input
								type="number"
								min="0"
								bind:value={minPrice}
								class="rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text focus:border-primary focus:outline-none"
							/>
						</label>
						<label class="flex flex-col gap-1">
							<span class="text-xs text-text-muted">Max price</span>
							<input
								type="number"
								min="0"
								bind:value={maxPrice}
								class="rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text focus:border-primary focus:outline-none"
							/>
						</label>
					{/if}

					<label class="col-span-2 flex flex-col gap-1">
						<span class="text-xs text-text-muted">Seed (optional, for reproducibility)</span>
						<input
							type="number"
							bind:value={seed}
							placeholder="Leave empty for random"
							class="rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text placeholder:text-text-muted/50 focus:border-primary focus:outline-none"
						/>
					</label>
				</div>

				<button
					onclick={generate}
					disabled={generating}
					class="mt-4 w-full rounded-xl bg-primary px-4 py-3 text-sm font-semibold text-white transition-all hover:bg-primary-dark disabled:opacity-50"
				>
					{generating ? 'Generating...' : 'Generate PDDL'}
				</button>

				{#if error}
					<p class="mt-2 text-sm text-error">{error}</p>
				{/if}
			</div>

			{#if pddlOutput}
				<div class="rounded-xl border border-border bg-surface p-5">
					<h2 class="mb-3 text-sm font-semibold uppercase tracking-wider text-text-muted">
						Save to File
					</h2>
					<div class="flex gap-2">
						<select
							bind:value={saveDir}
							class="rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text focus:border-primary focus:outline-none"
						>
							<option value="Basico">Basico</option>
							<option value="Extension_1">Extension_1</option>
							<option value="Extension_2">Extension_2</option>
							<option value="Extension_3">Extension_3</option>
							<option value="Extension_4">Extension_4</option>
							<option value="Extra_2">Extra_2</option>
						</select>
						<input
							type="text"
							bind:value={saveFilename}
							placeholder="filename"
							class="flex-1 rounded-lg border border-border bg-surface-light px-3 py-2 text-sm text-text focus:border-primary focus:outline-none"
						/>
						<button
							onclick={saveToFile}
							class="rounded-lg bg-success/20 px-4 py-2 text-sm font-medium text-success transition-colors hover:bg-success/30"
						>
							Save
						</button>
					</div>
					{#if saveMsg}
						<p class="mt-2 text-xs text-text-muted">{saveMsg}</p>
					{/if}
				</div>
			{/if}
		</div>

		<!-- Right: Preview -->
		<div class="flex flex-col gap-4">
			{#if pddlOutput}
				<div class="rounded-xl border border-border bg-surface p-5">
					<h2 class="mb-3 text-sm font-semibold uppercase tracking-wider text-text-muted">
						PDDL Output
					</h2>
					<PddlEditor value={pddlOutput} readonly />
				</div>

				{#if parsedProblem}
					<div class="rounded-xl border border-border bg-surface p-5">
						<h2 class="mb-3 text-sm font-semibold uppercase tracking-wider text-text-muted">
							Graph Preview
						</h2>
						<GraphPreview problem={parsedProblem} />
						<div class="mt-3 flex flex-wrap gap-4 text-xs text-text-muted">
							<span>
								<span class="mr-1 inline-block h-2.5 w-2.5 rounded-full bg-primary"></span>
								Cities ({parsedProblem.objects.cities.length})
							</span>
							<span>
								<span class="mr-1 inline-block h-2.5 w-2.5 rounded-full bg-warning"></span>
								Hotels ({parsedProblem.objects.hotels.length})
							</span>
							<span>Flights: {parsedProblem.flights.length}</span>
						</div>
					</div>
				{/if}
			{:else}
				<div class="flex flex-1 items-center justify-center rounded-xl border border-dashed border-border bg-surface p-12">
					<p class="text-center text-text-muted">
						Configure parameters and click <strong>Generate PDDL</strong> to see the output and graph preview.
					</p>
				</div>
			{/if}
		</div>
	</div>
</div>
