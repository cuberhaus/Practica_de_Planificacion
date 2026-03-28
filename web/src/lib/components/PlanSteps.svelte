<script lang="ts">
	import type { PlanResult } from '$lib/pddl';

	interface Props {
		plan: PlanResult;
	}

	let { plan }: Props = $props();
</script>

<div class="flex flex-col gap-3">
	{#if plan.steps.length === 0}
		<p class="text-sm text-text-muted">No plan steps found.</p>
	{:else}
		<div class="flex items-center gap-4 text-sm text-text-muted">
			<span>{plan.steps.length} step{plan.steps.length !== 1 ? 's' : ''}</span>
			{#if plan.totalCost !== null}
				<span>Total cost: <strong class="text-text">{plan.totalCost}</strong></span>
			{/if}
			{#if plan.route.length > 0}
				<span>Route: <strong class="text-primary-light">{plan.route.join(' → ')}</strong></span>
			{/if}
		</div>

		<div class="overflow-hidden rounded-lg border border-border">
			<table class="w-full text-left text-sm">
				<thead class="bg-surface-light text-text-muted">
					<tr>
						<th class="px-4 py-2 font-medium">#</th>
						<th class="px-4 py-2 font-medium">Action</th>
						<th class="px-4 py-2 font-medium">Parameters</th>
						{#if plan.steps.some((s) => s.cost !== null)}
							<th class="px-4 py-2 font-medium">Cost</th>
						{/if}
					</tr>
				</thead>
				<tbody>
					{#each plan.steps as step}
						<tr class="border-t border-border transition-colors hover:bg-surface-light/50">
							<td class="px-4 py-2 font-mono text-text-muted">{step.index + 1}</td>
							<td class="px-4 py-2 font-mono text-primary-light">{step.action}</td>
							<td class="px-4 py-2 font-mono text-text">{step.params.join(' ')}</td>
							{#if plan.steps.some((s) => s.cost !== null)}
								<td class="px-4 py-2 text-text-muted">{step.cost ?? '-'}</td>
							{/if}
						</tr>
					{/each}
				</tbody>
			</table>
		</div>
	{/if}
</div>
