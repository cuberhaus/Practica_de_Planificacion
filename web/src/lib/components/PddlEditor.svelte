<script lang="ts">
	import CodeMirror from 'svelte-codemirror-editor';
	import { oneDark } from '@codemirror/theme-one-dark';

	interface Props {
		value: string;
		readonly?: boolean;
		onchange?: (value: string) => void;
	}

	let { value = $bindable(), readonly = false, onchange }: Props = $props();

	function handleChange(newValue: string) {
		value = newValue;
		onchange?.(newValue);
	}
</script>

<div class="overflow-hidden rounded-lg border border-border">
	<CodeMirror
		bind:value
		theme={oneDark}
		{readonly}
		onchange={handleChange}
		styles={{
			'&': {
				fontSize: '13px',
				maxHeight: '500px'
			}
		}}
	/>
</div>
