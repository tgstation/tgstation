import { Button, Section, Stack } from 'tgui-core/components';
import { BooleanStyleMap, StringStyleMap } from 'tgui-core/ui';

import transparency_checkerboard from '../../../assets/transparency_checkerboard.svg';
import { colorsAreEqual, colorToCssString } from '../colorSpaces';
import { EditorColor } from '../Types/types';

export type PaletteProps = {
  colors: EditorColor[];
  selectedColor: EditorColor;
  onClickColor: (color: EditorColor, rightClick: boolean) => void;
  onClickAddColor: () => void;
  paletteButtonProps?: Partial<
    Exclude<BooleanStyleMap, 'inline'> & StringStyleMap
  >;
} & Parameters<typeof Stack>[0];

export const Palette = (props: PaletteProps) => {
  const {
    colors,
    selectedColor,
    onClickColor,
    onClickAddColor,
    paletteButtonProps,
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
              {...paletteButtonProps}
              onClick={() => onClickColor(color, false)}
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
        <Stack.Item m={0}>
          <Button
            inline
            disabled={
              colors.findIndex((color) =>
                colorsAreEqual(color, selectedColor),
              ) !== -1
            }
            icon="plus"
            {...paletteButtonProps}
            onClick={onClickAddColor}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};
