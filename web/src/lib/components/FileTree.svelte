<script lang="ts">
	interface Props {
		files: Array<{ name: string; path: string; dir: string }>;
		selected: string | null;
		onselect: (path: string) => void;
	}

	let { files, selected, onselect }: Props = $props();

	let grouped = $derived(
		files.reduce(
			(acc, f) => {
				if (!acc[f.dir]) acc[f.dir] = [];
				acc[f.dir].push(f);
				return acc;
			},
			{} as Record<string, typeof files>
		)
	);
</script>

<div class="flex flex-col gap-1">
	{#each Object.entries(grouped) as [dir, dirFiles]}
		<div class="mb-2">
			<p class="mb-1 px-2 text-xs font-semibold uppercase tracking-wider text-text-muted">
				{dir}
			</p>
			{#each dirFiles as file}
				<button
					onclick={() => onselect(file.path)}
					class="flex w-full items-center gap-2 rounded-md px-2 py-1.5 text-left text-sm transition-colors
						{selected === file.path
						? 'bg-primary/15 text-primary-light'
						: 'text-text-muted hover:bg-surface-lighter hover:text-text'}"
				>
					<span class="text-xs">📄</span>
					<span class="truncate">{file.name}</span>
				</button>
			{/each}
		</div>
	{/each}
</div>
