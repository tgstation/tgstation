/**
 * TGUI Base16 Theme
 * Based on TGUI color scheme defined in css variables
 * @see https://github.com/chriskempson/base16
 * @see https://github.com/tgstation/tgui-core/blob/main/styles/vars-colors.scss
 */
export const tgui16 = {
  scheme: 'ntos16',
  author: 'Aleksej Komarov et al., (https://github.com/tgstation)',
  // Backgrounds / UI surfaces
  base00: '#1A1A1A',
  base01: '#313234',
  base02: '#3a3a36',
  base03: '#6b6b5b',

  // Foreground / text
  base04: '#a59f85',
  base05: '#f8f8f2', // default text (near white)
  base06: '#f5f4f1',
  base07: '#f9f8f5',

  // Accent colors
  base08: '#f92672',
  base09: '#fd971f',
  base0A: '#f4bf75',
  base0B: '#5BA626', // --color-good
  base0C: '#a1efe4',
  base0D: '#47739E', // blue primary
  base0E: '#ae81ff',
  base0F: '#cc6633',
} as const;
