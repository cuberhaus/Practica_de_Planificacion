<script lang="ts">
</script>

<div class="mx-auto flex max-w-3xl flex-col items-center gap-8 pt-16">
	<h1 class="text-4xl font-bold text-text">
		<span class="text-primary-light">PDDL</span> Planning Interface
	</h1>
	<p class="text-center text-lg text-text-muted">
		A web interface for generating, editing, and solving PDDL planning problems
		for the travel agency domain.
	</p>

	<div class="mt-4 grid w-full grid-cols-3 gap-4">
		<a
			href="/generate"
			class="group flex flex-col gap-3 rounded-xl border border-border bg-surface p-6 transition-all hover:border-primary/50 hover:bg-surface-light"
		>
			<span class="text-3xl">⚡</span>
			<h2 class="text-lg font-semibold text-text group-hover:text-primary-light">Generate</h2>
			<p class="text-sm text-text-muted">
				Create PDDL problem instances with configurable parameters across 5 extension levels.
			</p>
		</a>

		<a
			href="/editor"
			class="group flex flex-col gap-3 rounded-xl border border-border bg-surface p-6 transition-all hover:border-primary/50 hover:bg-surface-light"
		>
			<span class="text-3xl">📝</span>
			<h2 class="text-lg font-semibold text-text group-hover:text-primary-light">Editor</h2>
			<p class="text-sm text-text-muted">
				Browse and edit PDDL domain and problem files with syntax highlighting.
			</p>
		</a>

		<a
			href="/planner"
			class="group flex flex-col gap-3 rounded-xl border border-border bg-surface p-6 transition-all hover:border-primary/50 hover:bg-surface-light"
		>
			<span class="text-3xl">🗺️</span>
			<h2 class="text-lg font-semibold text-text group-hover:text-primary-light">Planner</h2>
			<p class="text-sm text-text-muted">
				Run the automated planner and visualize travel routes on an interactive graph.
			</p>
		</a>
	</div>

	<div class="mt-8 rounded-xl border border-border bg-surface p-6">
		<h3 class="mb-3 text-sm font-semibold uppercase tracking-wider text-text-muted">Extension Levels</h3>
		<div class="grid grid-cols-5 gap-3 text-center text-sm">
			<div class="rounded-lg bg-surface-light p-3">
				<p class="font-medium text-text">Basico</p>
				<p class="text-xs text-text-muted">Cities + flights</p>
			</div>
			<div class="rounded-lg bg-surface-light p-3">
				<p class="font-medium text-text">Ext 1</p>
				<p class="text-xs text-text-muted">+ Days</p>
			</div>
			<div class="rounded-lg bg-surface-light p-3">
				<p class="font-medium text-text">Ext 2</p>
				<p class="text-xs text-text-muted">+ Interest</p>
			</div>
			<div class="rounded-lg bg-surface-light p-3">
				<p class="font-medium text-text">Ext 3</p>
				<p class="text-xs text-text-muted">+ Pricing</p>
			</div>
			<div class="rounded-lg bg-surface-light p-3">
				<p class="font-medium text-text">Ext 4</p>
				<p class="text-xs text-text-muted">All combined</p>
			</div>
		</div>
	</div>
</div>
