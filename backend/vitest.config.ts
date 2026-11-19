import { defineConfig } from 'vitest/config';

export default defineConfig({
  // Only the TypeScript sources; `npm run build` also emits compiled copies into dist/.
  test: { include: ['test/**/*.test.ts'] },
});
