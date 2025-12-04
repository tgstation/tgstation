/**
 * @file
 * @copyright 2023 itsmeow
 * @license MIT
 */
/**
 * EffigyEdit - This is an Effigy TGUI file
 */

import React, {
  createRef,
  useCallback,
  useEffect,
  useMemo,
  useState,
} from 'react';
import {
  type HsvaColor,
  hexToHsva,
  hsvaToHex,
  hsvaToHslString,
  hsvaToRgba,
  rgbaToHsva,
  validHex,
} from 'tgui-core/color';
import {
  Autofocus,
  Box,
  Button,
  Input,
  Interactive,
  NumberInput,
  Pointer,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { clamp } from 'tgui-core/math';
import { classes } from 'tgui-core/react';
import { useBackend } from '../backend';
import { Window } from '../layouts';
import { InputButtons } from './common/InputButtons';
import { Loader } from './common/Loader';

type Interaction = {
  left: number;
  top: number;
};

interface ColorPickerData {
  autofocus: boolean;
  buttons: string[];
  message: string;
  large_buttons: boolean;
  swapped_buttons: boolean;
  timeout: number;
  title: string;
  default_color: string;
}

type ColorPickerModalProps = any;

export const ColorPickerModal: React.FC<ColorPickerModalProps> = () => {
  const { data } = useBackend<ColorPickerData>();
  const { timeout, message, autofocus, default_color = '#000000' } = data;
  let { title } = data;

  const [selectedColor, setSelectedColor] = useState<HsvaColor>(
    hexToHsva(default_color),
  );

  useEffect(() => {
    setSelectedColor(hexToHsva(default_color));
  }, [default_color]);

  if (!title) {
    title = 'Colour Editor';
  }

  return (
    <Window
      height={message ? 465 : 430}
      title={title}
      width={700}
      theme="generic"
    >
      {!!timeout && <Loader value={timeout} />}
      <Window.Content>
        <Stack fill vertical>
          {!!autofocus && <Autofocus />}
          {message && (
            <Stack.Item>
              <Section fill>
                <Box color="label" overflow="hidden">
                  {message}
                </Box>
              </Section>
            </Stack.Item>
          )}
          <Stack.Item grow>
            <Section fill>
              <ColorSelector
                color={selectedColor}
                setColor={setSelectedColor}
                defaultColor={default_color}
              />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <InputButtons input={hsvaToHex(selectedColor)} />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

interface ColorPresetsProps {
  setColor: (color: HsvaColor) => void;
  setShowPresets: (show: boolean) => void;
}

const ColorPresets: React.FC<ColorPresetsProps> = React.memo(
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

interface ColorSelectorProps {
  color: HsvaColor;
  setColor: React.Dispatch<React.SetStateAction<HsvaColor>>;
  defaultColor: string;
}

const ColorSelector: React.FC<ColorSelectorProps> = React.memo(
  ({ color, setColor, defaultColor }) => {
    const handleChange = useCallback(
      (params: Partial<HsvaColor>) => {
        setColor((current) => ({ ...current, ...params }));
      },
      [setColor],
    );

    const [showPresets, setShowPresets] = useState<boolean>(false);
    const rgb = hsvaToRgba(color);
    const hexColor = hsvaToHex(color);

    return (
      <Stack direction="row">
        <Stack.Item mr={2} mt={2.5}>
          <Stack vertical>
            <Stack.Item>
              <div className="react-colorful">
                <SaturationValue hsva={color} onChange={handleChange} />
                <Hue
                  hue={color.h}
                  onChange={handleChange}
                  className="react-colorful__last-control"
                />
              </div>
            </Stack.Item>
            <Stack.Item mt={3}>
              <Box inline width="100px" height="20px" textAlign="center">
                New
              </Box>
              <Box inline width="100px" height="20px" textAlign="center">
                Existing
              </Box>
              <br />
              <Tooltip content={hexColor} position="bottom">
                <Box
                  inline
                  width="100px"
                  height="30px"
                  backgroundColor={hexColor}
                />
              </Tooltip>
              <Tooltip content={defaultColor} position="bottom">
                <Box
                  inline
                  width="100px"
                  height="30px"
                  backgroundColor={defaultColor}
                />
              </Tooltip>
            </Stack.Item>
          </Stack>
        </Stack.Item>
        <Stack.Item grow fontSize="15px" lineHeight="24px">
          {showPresets ? (
            <ColorPresets
              setColor={(c) => handleChange(c)}
              setShowPresets={setShowPresets}
            />
          ) : (
            <Stack vertical>
              <Stack.Item mt={5.5}>
                <Stack>
                  <Stack.Item>
                    <Box textColor="label">Hex:</Box>
                  </Stack.Item>
                  <Stack.Item grow>
                    <HexColorInput
                      fluid
                      color={hsvaToHex(color).substring(1)}
                      onChange={(value) => {
                        setColor(hexToHsva(value));
                      }}
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Button
                      icon="chevron-down"
                      onClick={() => setShowPresets(true)}
                    >
                      Skin Tones and Presets
                    </Button>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Divider mt={2} mb={2} />
              <HueRow color={color} handleChange={handleChange} />
              <SaturationRow color={color} handleChange={handleChange} />
              <ValueRow color={color} handleChange={handleChange} />
              <Stack.Divider mt={2} mb={2} />
              <RedRow color={color} handleChange={handleChange} />
              <GreenRow color={color} handleChange={handleChange} />
              <BlueRow color={color} handleChange={handleChange} />
            </Stack>
          )}
        </Stack.Item>
      </Stack>
    );
  },
);

interface RowProps {
  color: HsvaColor;
  handleChange: (c: Partial<HsvaColor>) => void;
}

const HueRow: React.FC<RowProps> = React.memo(({ color, handleChange }) => (
  <Stack.Item>
    <Stack>
      <Stack.Item width="25px">
        <Box textColor="label">H:</Box>
      </Stack.Item>
      <Stack.Item grow>
        <Hue hue={color.h} onChange={handleChange} />
      </Stack.Item>
      <Stack.Item>
        <TextSetter
          value={color.h}
          callback={(v) => handleChange({ h: v })}
          max={360}
          unit="°"
        />
      </Stack.Item>
    </Stack>
  </Stack.Item>
));

const SaturationRow: React.FC<RowProps> = React.memo(
  ({ color, handleChange }) => (
    <Stack.Item>
      <Stack>
        <Stack.Item width="25px">
          <Box textColor="label">S:</Box>
        </Stack.Item>
        <Stack.Item grow>
          <Saturation color={color} onChange={handleChange} />
        </Stack.Item>
        <Stack.Item>
          <TextSetter
            value={color.s}
            callback={(v) => handleChange({ s: v })}
            unit="%"
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  ),
);

const ValueRow: React.FC<RowProps> = React.memo(({ color, handleChange }) => (
  <Stack.Item>
    <Stack>
      <Stack.Item width="25px">
        <Box textColor="label">V:</Box>
      </Stack.Item>
      <Stack.Item grow>
        <Value color={color} onChange={handleChange} />
      </Stack.Item>
      <Stack.Item>
        <TextSetter
          value={color.v}
          callback={(v) => handleChange({ v })}
          unit="%"
        />
      </Stack.Item>
    </Stack>
  </Stack.Item>
));

interface RGBRowProps {
  color: HsvaColor;
  handleChange: (c: HsvaColor) => void;
}

const RedRow: React.FC<RGBRowProps> = React.memo(({ color, handleChange }) => {
  const rgb = hsvaToRgba(color);
  return (
    <Stack.Item>
      <Stack>
        <Stack.Item width="25px">
          <Box textColor="label">R:</Box>
        </Stack.Item>
        <Stack.Item grow>
          <RGBSlider color={color} onChange={handleChange} target="r" />
        </Stack.Item>
        <Stack.Item>
          <TextSetter
            value={rgb.r}
            callback={(v) => {
              handleChange(rgbaToHsva({ ...rgb, r: v }));
            }}
            max={255}
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
});

const GreenRow: React.FC<RGBRowProps> = React.memo(
  ({ color, handleChange }) => {
    const rgb = hsvaToRgba(color);
    return (
      <Stack.Item>
        <Stack>
          <Stack.Item width="25px">
            <Box textColor="label">G:</Box>
          </Stack.Item>
          <Stack.Item grow>
            <RGBSlider color={color} onChange={handleChange} target="g" />
          </Stack.Item>
          <Stack.Item>
            <TextSetter
              value={rgb.g}
              callback={(v) => {
                handleChange(rgbaToHsva({ ...rgb, g: v }));
              }}
              max={255}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    );
  },
);

const BlueRow: React.FC<RGBRowProps> = React.memo(({ color, handleChange }) => {
  const rgb = hsvaToRgba(color);
  return (
    <Stack.Item>
      <Stack>
        <Stack.Item width="25px">
          <Box textColor="label">B:</Box>
        </Stack.Item>
        <Stack.Item grow>
          <RGBSlider color={color} onChange={handleChange} target="b" />
        </Stack.Item>
        <Stack.Item>
          <TextSetter
            value={rgb.b}
            callback={(v) => {
              handleChange(rgbaToHsva({ ...rgb, b: v }));
            }}
            max={255}
          />
        </Stack.Item>
      </Stack>
    </Stack.Item>
  );
});

interface TextSetterProps {
  value: number;
  callback: (value: number) => void;
  min?: number;
  max?: number;
  unit?: string;
}

const TextSetter: React.FC<TextSetterProps> = React.memo(
  ({ value, callback, min = 0, max = 100, unit }) => {
    return (
      <NumberInput
        width="70px"
        value={Math.round(value)}
        step={1}
        minValue={min}
        maxValue={max}
        onChange={callback}
        unit={unit}
      />
    );
  },
);

interface HexColorInputProps {
  prefixed?: boolean;
  alpha?: boolean;
  color: string;
  fluid?: boolean;
  onChange: (newColor: string) => void;
}

const HexColorInput: React.FC<HexColorInputProps> = React.memo(
  ({ alpha, color, fluid, onChange, ...rest }) => {
    const initialColor = useMemo(() => {
      const stripped = color
        .replace(/[^0-9A-Fa-f]/g, '')
        .substring(0, 6)
        .toUpperCase();
      return stripped;
    }, [color]);

    const [localValue, setLocalValue] = useState(initialColor);

    useEffect(() => {
      setLocalValue(initialColor);
    }, [initialColor]);

    const isValidFullHex = useCallback(
      (val: string) => {
        return validHex(val, alpha) && val.length === 6;
      },
      [alpha],
    );

    const handleChangeEvent = (value: string) => {
      const strippedValue = value
        .replace(/[^0-9A-Fa-f]/g, '')
        .substring(0, 6)
        .toUpperCase();

      setLocalValue(strippedValue);

      if (isValidFullHex(strippedValue)) {
        onChange(strippedValue);
      }
    };

    const commitOrRevert = useCallback(() => {
      if (isValidFullHex(localValue)) {
        onChange(localValue);
      } else {
        setLocalValue(initialColor);
      }
    }, [initialColor, isValidFullHex, localValue, onChange]);

    const handleBlur = () => {
      commitOrRevert();
    };

    const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
      if (e.key === 'Enter') {
        commitOrRevert();
        (e.currentTarget as HTMLInputElement).blur();
      }
    };

    return (
      <Input
        fluid
        value={localValue}
        onChange={handleChangeEvent}
        onBlur={handleBlur}
        onKeyDown={handleKeyDown}
        {...rest}
      />
    );
  },
);

interface SaturationValueProps {
  hsva: HsvaColor;
  onChange: (newColor: Partial<HsvaColor>) => void;
}

const SaturationValue: React.FC<SaturationValueProps> = React.memo(
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

    return (
      <div className="react-colorful__saturation_value" style={containerStyle}>
        <Interactive
          containerRef={createRef<HTMLDivElement>()}
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

const Hue: React.FC<HueProps> = React.memo(({ className, hue, onChange }) => {
  const handleMove = (interaction: Interaction) => {
    onChange({ h: 360 * interaction.left });
  };

  const handleKey = (offset: Interaction) => {
    onChange({ h: clamp(hue + offset.left * 360, 0, 360) });
  };

  const nodeClassName = classes(['react-colorful__hue', className]);

  return (
    <div className={nodeClassName}>
      <Interactive
        containerRef={createRef<HTMLDivElement>()}
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
});

interface SaturationProps {
  className?: string;
  color: HsvaColor;
  onChange: (newSaturation: Partial<HsvaColor>) => void;
}

const Saturation: React.FC<SaturationProps> = React.memo(
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

    return (
      <div className={nodeClassName}>
        <Interactive
          containerRef={createRef<HTMLDivElement>()}
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

const Value: React.FC<ValueProps> = React.memo(
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

    return (
      <div className={nodeClassName}>
        <Interactive
          style={{
            background,
          }}
          containerRef={createRef<HTMLDivElement>()}
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

const RGBSlider: React.FC<RGBSliderProps> = React.memo(
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

    return (
      <div className={nodeClassName}>
        <Interactive
          containerRef={createRef<HTMLDivElement>()}
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

// Used for the colour picker, and anything else that wants a list of preset colours.
const colorList = [
  ['003366', '336699', '3366CC', '003399', '000099', '0000CC', '000066'],
  [
    '006666',
    '006699',
    '0099CC',
    '0066CC',
    '0033CC',
    '0000FF',
    '3333FF',
    '333399',
  ],
  [
    '008080',
    '009999',
    '33CCCC',
    '00CCFF',
    '0099FF',
    '0066FF',
    '3366FF',
    '3333CC',
    '666699',
  ],
  [
    '339966',
    '00CC99',
    '00FFCC',
    '00FFFF',
    '33CCFF',
    '3399FF',
    '6699FF',
    '6666FF',
    '6600FF',
    '6600CC',
  ],
  [
    '339933',
    '00CC66',
    '00FF99',
    '66FFCC',
    '66FFFF',
    '66CCFF',
    '99CCFF',
    '9999FF',
    '9966FF',
    '9933FF',
    '9900FF',
  ],
  [
    '006600',
    '00CC00',
    '00FF00',
    '66FF99',
    '99FFCC',
    'CCFFFF',
    'CCECFF',
    'CCCCFF',
    'CC99FF',
    'CC66FF',
    'CC00FF',
    '9900CC',
  ],
  [
    '003300',
    '008000',
    '33CC33',
    '66FF66',
    '99FF99',
    'CCFFCC',
    'FFFFFF',
    'FFCCFF',
    'FF99FF',
    'FF66FF',
    'FF00FF',
    'CC00CC',
    '660066',
  ],
  [
    '336600',
    '009900',
    '66FF33',
    '99FF66',
    'CCFF99',
    'FFFFCC',
    'FFCCCC',
    'FF99CC',
    'FF66CC',
    'FF33CC',
    'CC0099',
    '800080',
  ],
  [
    '333300',
    '669900',
    '99FF33',
    'CCFF66',
    'FFFF99',
    'FFCC99',
    'FF9999',
    'FF6699',
    'FF3399',
    'CC3399',
    '990099',
  ],
  [
    '666633',
    '99CC00',
    'CCFF33',
    'FFFF66',
    'FFCC66',
    'FF9966',
    'FF7C80',
    'FF0066',
    'D60093',
    '993366',
  ],
  [
    '808000',
    'CCCC00',
    'FFFF00',
    'FFCC00',
    'FF9933',
    'FF6600',
    'FF5050',
    'CC0066',
    '660033',
  ],
  [
    '996633',
    'CC9900',
    'FF9900',
    'CC6600',
    'FF3300',
    'FF0000',
    'CC0000',
    '990033',
  ],
  ['663300', '996600', 'CC3300', '993300', '990000', '800000', 'A50021'],
  [
    'F8F8F8',
    'DDDDDD',
    'B2B2B2',
    '808080',
    '5F5F5F',
    '333333',
    '1C1C1C',
    '080808',
  ],
  [
    'FFFFFF',
    'EAEAEA',
    'C0C0C0',
    '969696',
    '777777',
    '4D4D4D',
    '292929',
    '111111',
    '000000',
  ],
  [
    'f0197d',
    'ff7f50',
    'ffe45e',
    '21fa90',
    '7df9ff',
    '2ccaff',
    '21649f',
    '7b55dd',
    'b81fff',
    'ff5cad',
  ],
  [
    'ffe2db',
    'ffd5cc',
    'feb8a0',
    'eaa78d',
    'e7a992',
    'd49487',
    'facca4',
    'e8b782',
    'ffc905',
  ],
  [
    'c48c5e',
    'bd7740',
    'ab7968',
    '8c553f',
    '755246',
    '86655b',
    '754223',
    '471b18',
  ],
];
