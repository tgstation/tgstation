/**
 * @file
 * @copyright 2021 AnturK https://github.com/AnturK
 * @license MIT
 */

console.log('tgfont: Generating font kit');

// Change working directory to project root
process.chdir(__dirname);

// Silently make a dist folder
try {
  require('fs').mkdirSync('dist');
}
catch (err) {}

const { generateFonts } = require('fantasticon');

generateFonts({
  name: 'tgfont',
  inputDir: './icons',
  outputDir: './dist',
  // We currently disable woff2 due to ttf2woff2 causing OOM in WASM
  // Related: https://github.com/nfroidure/ttf2woff2/issues/38
  fontTypes: [
    // 'woff2', // Supported by all browsers except IE8
    'eot', // Supported exclusively by IE6-11
  ],
  assetTypes: ['css'],
  prefix: 'tg',
}).then((results) => {
  // eslint-disable-next-line max-len
  console.log(`tgfont: Processed ${Object.keys(results.assetsIn).length} icons`);
  for (const file of results.writeResults) {
    console.log(`tgfont: Generated '${file.writePath}'`);
  }
});
