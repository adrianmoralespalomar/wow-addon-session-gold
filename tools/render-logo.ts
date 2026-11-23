import { Resvg } from '@resvg/resvg-js';
import { readFileSync, writeFileSync } from 'node:fs';
import { resolve } from 'node:path';

/** Renders `assets/logo.svg` to the PNG used as the CurseForge project avatar (at least 400×400). */
const LOGO_SIZE_PX = 512;
const ASSETS_DIRECTORY = resolve(import.meta.dirname, '../assets');

const png = new Resvg(readFileSync(resolve(ASSETS_DIRECTORY, 'logo.svg')), { fitTo: { mode: 'width', value: LOGO_SIZE_PX } }).render().asPng();
writeFileSync(resolve(ASSETS_DIRECTORY, 'logo.png'), png);
console.log(`assets/logo.png (${LOGO_SIZE_PX}×${LOGO_SIZE_PX})`);
