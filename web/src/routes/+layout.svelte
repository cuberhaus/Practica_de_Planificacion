<script lang="ts">
	import '../app.css';
	import { page } from '$app/state';

	interface Props {
		children: import('svelte').Snippet;
	}

	let { children }: Props = $props();

	const navItems = [
		{ href: '/', label: 'Home', icon: '🏠' },
		{ href: '/generate', label: 'Generate', icon: '⚡' },
		{ href: '/editor', label: 'Editor', icon: '📝' },
		{ href: '/planner', label: 'Planner', icon: '🗺️' }
	];

	let sidebarOpen = $state(true);
</script>

<div class="flex h-screen overflow-hidden">
	<aside
		class="flex flex-col border-r border-border bg-surface transition-all duration-200 {sidebarOpen
			? 'w-56'
			: 'w-16'}"
	>
		<div class="flex h-14 items-center gap-2 border-b border-border px-4">
			{#if sidebarOpen}
				<span class="text-lg font-bold text-primary-light">PDDL Planner</span>
			{/if}
			<button
				onclick={() => (sidebarOpen = !sidebarOpen)}
				class="ml-auto rounded-md p-1.5 text-text-muted transition-colors hover:bg-surface-lighter hover:text-text"
			>
				{sidebarOpen ? '◀' : '▶'}
			</button>
		</div>

		<nav class="flex flex-1 flex-col gap-1 p-2">
			{#each navItems as item}
				{@const active = page.url.pathname === item.href || (item.href !== '/' && page.url.pathname.startsWith(item.href))}
				<a
					href={item.href}
					class="flex items-center gap-3 rounded-lg px-3 py-2.5 text-sm font-medium transition-colors
						{active
						? 'bg-primary/15 text-primary-light'
						: 'text-text-muted hover:bg-surface-lighter hover:text-text'}"
				>
					<span class="text-lg">{item.icon}</span>
					{#if sidebarOpen}
						<span>{item.label}</span>
					{/if}
				</a>
			{/each}
		</nav>

		<div class="border-t border-border p-3">
			{#if sidebarOpen}
				<p class="text-xs text-text-muted">Practica de Planificacion</p>
			{/if}
		</div>
	</aside>

	<main class="flex-1 overflow-y-auto bg-[#181825] p-6">
		{@render children()}
	</main>
</div>
