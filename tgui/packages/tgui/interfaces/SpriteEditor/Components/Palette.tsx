import transparency_checkerboard from 'tgui/assets/transparency_checkerboard.svg';
import { Button, Section, Stack } from 'tgui-core/components';
import { KEY_DELETE } from 'tgui-core/keycodes';
import type { BooleanStyleMap, StringStyleMap } from 'tgui-core/ui';

import { colorsAreEqual, colorToCssString } from '../colorSpaces';
import type { EditorColor } from '../Types/types';

export type PaletteProps = {
  colors: EditorColor[];
  selectedColor: EditorColor;
  onClickColor: (color: EditorColor, rightClick: boolean) => void;
  onClickAddColor: () => void;
  onRemoveColor: (index: number) => void;
  paletteButtonProps?: Partial<
    Exclude<BooleanStyleMap, 'inline'> & StringStyleMap
  >;
  maxColors?: number;
} & Parameters<typeof Stack>[0];

export const Palette = (props: PaletteProps) => {
  const {
    colors,
    selectedColor,
    onClickColor,
    onClickAddColor,
    onRemoveColor,
    paletteButtonProps,
    maxColors = Infinity,
    style,
    ...rest
  } = props;
  return (
    <Section title="Palette">
      <Stack {...rest} style={{ ...style, flexWrap: 'wrap', gap: '0.5rem' }}>
        {colors.map((color, i) => (
          <Stack.Item key={i} m={0}>
            <Button
              inline
              selected={colorsAreEqual(color, selectedColor)}
              width="2em"
              height="2em"
              {...paletteButtonProps}
              onClick={() => onClickColor(color, false)}
              onMouseOver={(ev) => ev.currentTarget.focus()}
              onKeyDown={(ev) => {
                if (ev.keyCode === KEY_DELETE) {
                  onRemoveColor(i + 1);
                  ev.preventDefault();
                }
              }}
              onContextMenu={(ev) => {
                onClickColor(color, true);
                ev.preventDefault();
              }}
              style={{
                backgroundImage: `linear-gradient(${colorToCssString(color)}, ${colorToCssString(color)}), url(${transparency_checkerboard})`,
              }}
            />
          </Stack.Item>
        ))}
        {maxColors > 1 && (
          <Stack.Item m={0}>
            <Button
              inline
              disabled={
                colors.length === maxColors ||
                colors.findIndex((color) =>
                  colorsAreEqual(color, selectedColor),
                ) !== -1
              }
              icon="plus"
              width="2em"
              height="2em"
              {...paletteButtonProps}
              onClick={onClickAddColor}
            />
          </Stack.Item>
        )}
      </Stack>
    </Section>
  );
};
