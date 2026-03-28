import { sveltekit } from '@sveltejs/kit/vite';
// @ts-expect-error -- @tailwindcss/vite has no type declarations
import tailwindcss from '@tailwindcss/vite';
import { defineConfig } from 'vite';

export default defineConfig({
	plugins: [tailwindcss(), sveltekit()]
});
