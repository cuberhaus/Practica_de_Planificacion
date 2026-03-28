<script lang="ts">
	import FileTree from '$lib/components/FileTree.svelte';
	import PddlEditor from '$lib/components/PddlEditor.svelte';
	import GraphPreview from '$lib/components/GraphPreview.svelte';
	import { parsePddlProblem, type PddlProblem } from '$lib/pddl';

	let { data } = $props();

	let selectedPath = $state<string | null>(null);
	let editorContent = $state('');
	let originalContent = $state('');
	let loading = $state(false);
	let saving = $state(false);
	let message = $state('');
	let showGraph = $state(false);

	let hasChanges = $derived(editorContent !== originalContent);
	let parsedProblem = $derived<PddlProblem | null>(
		showGraph && editorContent ? parsePddlProblem(editorContent) : null
	);
	let isDomain = $derived(selectedPath ? selectedPath.includes('domain') : false);

	async function loadFile(path: string) {
		selectedPath = path;
		loading = true;
		message = '';
		try {
			const res = await fetch(`/api/files?path=${encodeURIComponent(path)}`);
			if (!res.ok) throw new Error('Failed to load file');
			const data = await res.json();
			editorContent = data.content;
			originalContent = data.content;
			showGraph = !path.includes('domain');
		} catch {
			message = 'Failed to load file';
		} finally {
			loading = false;
		}
	}

	async function save() {
		if (!selectedPath) return;
		saving = true;
		message = '';
		try {
			const res = await fetch('/api/files', {
				method: 'PUT',
				headers: { 'Content-Type': 'application/json' },
				body: JSON.stringify({ path: selectedPath, content: editorContent })
			});
			if (!res.ok) throw new Error('Failed to save');
			originalContent = editorContent;
			message = 'Saved successfully';
			setTimeout(() => (message = ''), 3000);
		} catch {
			message = 'Failed to save';
		} finally {
			saving = false;
		}
	}
</script>

<div class="flex h-full flex-col gap-4">
	<h1 class="text-2xl font-bold text-text">
		<span class="text-primary-light">📝</span> PDDL Editor
	</h1>

	<div class="grid flex-1 grid-cols-[220px_1fr] gap-4 overflow-hidden">
		<!-- File Tree -->
		<div class="overflow-y-auto rounded-xl border border-border bg-surface p-3">
			<h2 class="mb-3 text-xs font-semibold uppercase tracking-wider text-text-muted">
				Files
			</h2>
			<FileTree files={data.files} selected={selectedPath} onselect={loadFile} />
		</div>

		<!-- Editor Area -->
		<div class="flex flex-col gap-4 overflow-hidden">
			{#if selectedPath}
				<div class="flex items-center gap-3">
					<span class="font-mono text-sm text-text-muted">{selectedPath}</span>
					{#if hasChanges}
						<span class="rounded-full bg-warning/20 px-2 py-0.5 text-xs text-warning">
							unsaved
						</span>
					{/if}
					<div class="ml-auto flex items-center gap-2">
						{#if !isDomain}
							<button
								onclick={() => (showGraph = !showGraph)}
								class="rounded-lg border border-border px-3 py-1.5 text-xs text-text-muted transition-colors hover:bg-surface-lighter hover:text-text"
							>
								{showGraph ? 'Hide' : 'Show'} Graph
							</button>
						{/if}
						<button
							onclick={save}
							disabled={!hasChanges || saving}
							class="rounded-lg bg-primary px-4 py-1.5 text-xs font-medium text-white transition-all hover:bg-primary-dark disabled:opacity-40"
						>
							{saving ? 'Saving...' : 'Save'}
						</button>
					</div>
				</div>

				{#if message}
					<p class="text-xs text-success">{message}</p>
				{/if}

				{#if loading}
					<div class="flex flex-1 items-center justify-center">
						<p class="text-text-muted">Loading...</p>
					</div>
				{:else}
					<div class="grid gap-4 {showGraph && parsedProblem ? 'grid-cols-[1fr_1fr]' : ''}">
						<div class="min-h-0 overflow-auto">
							<PddlEditor bind:value={editorContent} />
						</div>
						{#if showGraph && parsedProblem}
							<GraphPreview problem={parsedProblem} />
						{/if}
					</div>
				{/if}
			{:else}
				<div class="flex flex-1 items-center justify-center rounded-xl border border-dashed border-border bg-surface">
					<p class="text-text-muted">Select a file from the sidebar to start editing.</p>
				</div>
			{/if}
		</div>
	</div>
</div>
