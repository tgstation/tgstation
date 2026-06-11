/**
 * @file
 * @copyright 2023 itsmeow
 * @license MIT
 */
import React, { useMemo, useRef } from 'react';
import {
  type HsvaColor,
  hexToHsva,
  hsvaToHslString,
  hsvaToRgba,
  rgbaToHsva,
} from 'tgui-core/color';
import { Box, Button, type Interaction, Interactive, Pointer, Stack } from 'tgui-core/components';
import { clamp } from 'tgui-core/math';
import { classes } from 'tgui-core/react';
import { colorList } from './ColorPresets';

interface ColorPresetsProps {
  setColor: (color: HsvaColor) => void;
  setShowPresets: (show: boolean) => void;
}

export const ColorPresets: React.FC<ColorPresetsProps> = React.memo(
  ({ setColor, setShowPresets }) => {
    return (
      <>
        <Button
          onClick={() => setShowPresets(false)}
          position="absolute"
          right="4px"
          icon="chevron-up"
        >
          Hide
        </Button>
        <Stack justify="center">
          <Stack.Item>
            {colorList.map((row, index) => (
              <Stack.Item key={index} width="100%">
                <Stack justify="center">
                  {row.map((entry) => (
                    <Box key={entry} p="1px" backgroundColor="black">
                      <Box
                        p="1px"
                        backgroundColor="#454C5F"
                        onClick={() => setColor(hexToHsva(entry))}
                      >
                        <Box
                          backgroundColor={`#${entry}`}
                          width="24px"
                          height="16px"
                        />
                      </Box>
                    </Box>
                  ))}
                </Stack>
              </Stack.Item>
            ))}
          </Stack.Item>
        </Stack>
      </>
    );
  },
);

interface SaturationValueProps {
  hsva: HsvaColor;
  onChange: (newColor: Partial<HsvaColor>) => void;
}

export const SaturationValue: React.FC<SaturationValueProps> = React.memo(
  ({ hsva, onChange }) => {
    const handleMove = (interaction: Interaction) => {
      onChange({
        s: interaction.left * 100,
        v: 100 - interaction.top * 100,
      });
    };

    const handleKey = (offset: Interaction) => {
      onChange({
        s: clamp(hsva.s + offset.left * 100, 0, 100),
        v: clamp(hsva.v - offset.top * 100, 0, 100),
      });
    };

    const containerStyle = useMemo(
      () => ({
        backgroundColor: hsvaToHslString({
          h: hsva.h,
          s: 100,
          v: 100,
          a: 1,
        }),
      }),
      [hsva.h],
    );

    const containerRef = useRef<HTMLDivElement>(null);

    return (
      <div className="react-colorful__saturation_value" style={containerStyle}>
        <Interactive
          containerRef={containerRef}
          onMove={handleMove}
          onKey={handleKey}
          aria-label="Color"
          aria-valuetext={`Saturation ${Math.round(
            hsva.s,
          )}%, Brightness ${Math.round(hsva.v)}%`}
        >
          <Pointer
            className="react-colorful__saturation_value-pointer"
            top={1 - hsva.v / 100}
            left={hsva.s / 100}
            color={hsvaToHslString(hsva)}
          />
        </Interactive>
      </div>
    );
  },
);

interface HueProps {
  className?: string;
  hue: number;
  onChange: (newHue: Partial<HsvaColor>) => void;
}

export const Hue: React.FC<HueProps> = React.memo(
  ({ className, hue, onChange }) => {
    const handleMove = (interaction: Interaction) => {
      onChange({ h: 360 * interaction.left });
    };

    const handleKey = (offset: Interaction) => {
      onChange({ h: clamp(hue + offset.left * 360, 0, 360) });
    };

    const nodeClassName = classes(['react-colorful__hue', className]);
    const containerRef = useRef<HTMLDivElement>(null);

    return (
      <div className={nodeClassName}>
        <Interactive
          containerRef={containerRef}
          onMove={handleMove}
          onKey={handleKey}
          aria-label="Hue"
          aria-valuenow={Math.round(hue)}
          aria-valuemax={360}
          aria-valuemin={0}
        >
          <Pointer
            className="react-colorful__hue-pointer"
            left={hue / 360}
            color={hsvaToHslString({ h: hue, s: 100, v: 100, a: 1 })}
          />
        </Interactive>
      </div>
    );
  },
);

interface SaturationProps {
  className?: string;
  color: HsvaColor;
  onChange: (newSaturation: Partial<HsvaColor>) => void;
}

export const Saturation: React.FC<SaturationProps> = React.memo(
  ({ className, color, onChange }) => {
    const handleMove = (interaction: Interaction) => {
      onChange({ s: 100 * interaction.left });
    };

    const handleKey = (offset: Interaction) => {
      onChange({ s: clamp(color.s + offset.left * 100, 0, 100) });
    };

    const nodeClassName = classes(['react-colorful__saturation', className]);

    const background = useMemo(
      () =>
        `linear-gradient(to right, ${hsvaToHslString({
          h: color.h,
          s: 0,
          v: color.v,
          a: 1,
        })}, ${hsvaToHslString({ h: color.h, s: 100, v: color.v, a: 1 })})`,
      [color],
    );
    const containerRef = useRef<HTMLDivElement>(null);

    return (
      <div className={nodeClassName}>
        <Interactive
          containerRef={containerRef}
          style={{ background }}
          onMove={handleMove}
          onKey={handleKey}
          aria-label="Saturation"
          aria-valuenow={Math.round(color.s)}
          aria-valuemax={100}
          aria-valuemin={0}
        >
          <Pointer
            className="react-colorful__saturation-pointer"
            left={color.s / 100}
            color={hsvaToHslString({
              h: color.h,
              s: color.s,
              v: color.v,
              a: 1,
            })}
          />
        </Interactive>
      </div>
    );
  },
);

interface ValueProps {
  className?: string;
  color: HsvaColor;
  onChange: (newValue: Partial<HsvaColor>) => void;
}

export const Value: React.FC<ValueProps> = React.memo(
  ({ className, color, onChange }) => {
    const handleMove = (interaction: Interaction) => {
      onChange({ v: 100 * interaction.left });
    };

    const handleKey = (offset: Interaction) => {
      onChange({
        v: clamp(color.v + offset.left * 100, 0, 100),
      });
    };

    const nodeClassName = classes(['react-colorful__value', className]);

    const background = useMemo(
      () =>
        `linear-gradient(to right, ${hsvaToHslString({
          h: color.h,
          s: color.s,
          v: 0,
          a: 1,
        })}, ${hsvaToHslString({ h: color.h, s: color.s, v: 100, a: 1 })})`,
      [color],
    );
    const containerRef = useRef<HTMLDivElement>(null);

    return (
      <div className={nodeClassName}>
        <Interactive
          style={{
            background,
          }}
          containerRef={containerRef}
          onMove={handleMove}
          onKey={handleKey}
          aria-label="Value"
          aria-valuenow={Math.round(color.v)}
          aria-valuemax={100}
          aria-valuemin={0}
        >
          <Pointer
            className="react-colorful__value-pointer"
            left={color.v / 100}
            color={hsvaToHslString(color)}
          />
        </Interactive>
      </div>
    );
  },
);

interface RGBSliderProps {
  className?: string;
  color: HsvaColor;
  onChange: (newValue: HsvaColor) => void;
  target: 'r' | 'g' | 'b';
}

export const RGBSlider: React.FC<RGBSliderProps> = React.memo(
  ({ className, color, onChange, target }) => {
    const rgb = hsvaToRgba(color);

    const setNewTarget = (value: number) => {
      const newRgb = { ...rgb, [target]: value };
      onChange(rgbaToHsva(newRgb));
    };

    const handleMove = (interaction: Interaction) => {
      setNewTarget(255 * interaction.left);
    };

    const handleKey = (offset: Interaction) => {
      setNewTarget(clamp(rgb[target] + offset.left * 255, 0, 255));
    };

    const nodeClassName = classes([`react-colorful__${target}`, className]);

    const channels = {
      r: `rgb(${Math.round(rgb.r)},0,0)`,
      g: `rgb(0,${Math.round(rgb.g)},0)`,
      b: `rgb(0,0,${Math.round(rgb.b)})`,
    };

    const selected = channels[target];
    const containerRef = useRef<HTMLDivElement>(null);

    return (
      <div className={nodeClassName}>
        <Interactive
          containerRef={containerRef}
          onMove={handleMove}
          onKey={handleKey}
          aria-valuenow={rgb[target]}
          aria-valuemax="100"
          aria-valuemin="0"
        >
          <Pointer
            className={`react-colorful__${target}-pointer`}
            left={rgb[target] / 255}
            color={selected}
          />
        </Interactive>
      </div>
    );
  },
);
