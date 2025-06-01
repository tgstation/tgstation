import svgtofont from 'svgtofont';

/** @type {import('svgtofont').SvgToFontOptions} */
const config = {
  classNamePrefix: 'tg',
  css: {
    include: /\.css$/,
  },
  dist: './dist',
  emptyDist: true,
  excludeFormat: ['eot', 'svg', 'symbol.svg', 'ttf', 'woff'],
  fontName: 'tgfont',
  src: './icons',
  svgicons2svgfont: {
    normalize: true,
  },
  useCSSVars: true,
};

svgtofont(config).catch(console.error);
