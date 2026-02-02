import { type ReactNode, useCallback, useRef, useState } from 'react';
import transparency_checkerboard from 'tgui/assets/transparency_checkerboard.svg';
import {
  Box,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { clamp01 } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';
import {
  type BooleanStyleMap,
  computeBoxProps,
  type StringStyleMap,
} from 'tgui-core/ui';
import {
  asBothSpaces,
  hsva2hslString,
  parseHexColorString,
  rgb2hexstring,
} from '../colorSpaces';
import {
  invLerp,
  lerp,
  useClickAndDragEventHandler,
  useDimensions,
} from '../helpers';
import {
  type EditorColor,
  type InlineStyle,
  SpriteEditorColorMode,
} from '../Types/types';

type TouchpadEventHandler = (
  event: MouseEvent,
  ref: React.RefObject<HTMLDivElement>,
) => void;

type TouchpadProps = {
  onMouseDown: TouchpadEventHandler;
  onMouseMove: TouchpadEventHandler;
  onMouseUp: TouchpadEventHandler;
  elementRef: React.RefObject<HTMLElement | null>;
  children: ReactNode;
};

const Touchpad = (props: TouchpadProps) => {
  const { onMouseDown, onMouseMove, onMouseUp, elementRef, children } = props;
  const fallbackRef = useRef<HTMLDivElement>(null);
  const usedRef = elementRef ?? fallbackRef;
  const mouseDownHandler = useClickAndDragEventHandler(
    usedRef,
    onMouseDown,
    onMouseMove,
    onMouseUp,
  );
  return (
    <div ref={fallbackRef} onMouseDown={mouseDownHandler}>
      {children}
    </div>
  );
};

type SliderMarkerProps = Partial<{
  length: string | BooleanLike;
  crossLength: string | BooleanLike;
  vertical: BooleanLike;
}>;

type SliderCallback = (value: number) => void;

type SliderProps = SliderMarkerProps & {
  backgroundImage: string;
  markerPosition?: number;
  markerColor: string;
  markerOutlineColor?: string;
  onDrag: SliderCallback;
  onRelease: SliderCallback;
};

const computeSliderValue = (
  event: MouseEvent,
  ref: React.RefObject<HTMLElement>,
  vertical: BooleanLike,
) => {
  const current = ref.current;
  if (!current) {
    return 0;
  }
  const { clientX, clientY } = event;
  const { top, left, width, height } = current.getBoundingClientRect();
  return clamp01(
    vertical ? (clientY - top) / height : (clientX - left) / width,
  );
};

const Slider = (props: SliderProps) => {
  const {
    length,
    crossLength,
    vertical,
    backgroundImage,
    markerPosition = 0,
    markerColor,
    markerOutlineColor,
    onDrag,
    onRelease,
  } = props;
  const touchpadRef = useRef<HTMLDivElement>(null);
  const dragHandler = useCallback<TouchpadEventHandler>(
    (event, ref) => {
      const value = computeSliderValue(event, ref, vertical);
      onDrag(value);
    },
    [onDrag],
  );
  const releaseHandler = useCallback<TouchpadEventHandler>(
    (event, ref) => {
      const value = computeSliderValue(event, ref, vertical);
      onRelease(value);
    },
    [onRelease],
  );
  const dimensions = vertical
    ? {
        height: length,
        width: crossLength,
      }
    : {
        width: length,
        height: crossLength,
      };
  const valueOffset = `calc(${markerPosition * 100}% - 0.25em)`;
  return (
    <Box position="relative">
      <Touchpad
        onMouseDown={dragHandler}
        onMouseMove={dragHandler}
        onMouseUp={releaseHandler}
        elementRef={touchpadRef}
      >
        <div
          ref={touchpadRef}
          {...computeBoxProps({
            ...dimensions,
            style: {
              backgroundImage: backgroundImage,
              outline: '2px solid black',
              borderRadius: '2px',
            },
          })}
        />
        <div
          {...computeBoxProps({
            position: 'absolute',
            width: `calc(${crossLength} * ${vertical ? 1.2 : 0.25})`,
            height: `calc(${crossLength} * ${vertical ? 0.25 : 1.2})`,
            [`${vertical ? 'top' : 'left'}`]: valueOffset,
            [`${vertical ? 'left' : 'top'}`]: `calc(${crossLength} * -0.1)`,
            style: {
              outline: `2px solid ${markerOutlineColor ?? 'black'}`,
              borderRadius: '2px',
              backgroundImage: `linear-gradient(${markerColor}, ${markerColor}), url(${transparency_checkerboard})`,
            },
          })}
        />
      </Touchpad>
    </Box>
  );
};

type SatValPadCallback = (x: number, y: number) => void;

type SatValPadProps = {
  hue: number;
  saturation: number;
  value: number;
  width?: string | BooleanLike;
  onDrag: SatValPadCallback;
  onRelease: SatValPadCallback;
};

const computeSatValTouchpadValue = (
  ev: MouseEvent,
  ref: React.RefObject<HTMLDivElement | null>,
): [number, number] => {
  const current = ref.current;
  if (!current) {
    return [0, 0];
  }
  const { clientX, clientY } = ev;
  const { left, top, width, height } = current.getBoundingClientRect();
  return [clamp01((clientX - left) / width), clamp01((clientY - top) / height)];
};

const SatValPad = (props: SatValPadProps) => {
  const { hue, saturation, value, width, onDrag, onRelease } = props;
  const touchpadRef = useRef<HTMLDivElement>(null);
  const outerRef = useRef<HTMLDivElement>(null);
  const [dragging, setDragging] = useState<boolean>(false);
  const [touchpadWidth] = useDimensions(outerRef);
  const dragHandler = useCallback(
    (ev) => {
      const [x, y] = computeSatValTouchpadValue(ev, touchpadRef);
      onDrag(x, y);
    },
    [touchpadRef, onDrag],
  );
  const releaseHandler = useCallback(
    (ev) => {
      const [x, y] = computeSatValTouchpadValue(ev, touchpadRef);
      onRelease(x, y);
    },
    [touchpadRef, onRelease],
  );
  return (
    <div
      {...computeBoxProps({
        position: 'relative',
        width,
        style: { aspectRatio: 1 },
      })}
      ref={outerRef}
    >
      <Touchpad
        onMouseDown={(ev) => {
          setDragging(true);
          dragHandler(ev);
        }}
        onMouseMove={dragHandler}
        onMouseUp={(ev) => {
          setDragging(false);
          releaseHandler(ev);
        }}
        elementRef={touchpadRef}
      >
        <div
          ref={touchpadRef}
          {...computeBoxProps({
            width: `${touchpadWidth}px`,
            height: `${touchpadWidth}px`,
            style: {
              outline: '2px solid black',
              backgroundImage: `linear-gradient(to top, rgba(0, 0, 0, 1), rgba(0, 0, 0, 0)), linear-gradient(to right, ${hsva2hslString({ h: hue, s: 0, v: 1 })}, ${hsva2hslString({ h: hue, s: 1, v: 1 })})`,
            },
          })}
        />
        <div
          {...computeBoxProps({
            position: 'absolute',
            width: `${dragging ? 1.5 : 1}em`,
            height: `${dragging ? 1.5 : 1}em`,
            backgroundColor: hsva2hslString({
              h: hue,
              s: saturation,
              v: value,
            }),
            top: `calc(${(1 - value) * 100}% - ${dragging ? 0.75 : 0.5}em)`,
            left: `calc(${saturation * 100}% - ${dragging ? 0.75 : 0.5}em`,
            style: {
              border: `2px solid ${value >= 0.5 ? 'black' : 'white'}`,
              borderRadius: '50%',
            },
          })}
        />
      </Touchpad>
    </div>
  );
};

type PickerComponentRowProps = {
  markerColor: string;
  whiteMarkerBorder?: boolean;
  backgroundImage: string;
  value: number;
  max: number;
  unit?: string;
  numberInputMultiplier?: number;
  numberInputFormat?: (value: number) => string;
  onDrag: (number) => void;
  onRelease: (number) => void;
};

const PickerComponentRow = (props: PickerComponentRowProps) => {
  const {
    markerColor,
    whiteMarkerBorder = false,
    backgroundImage,
    value,
    max,
    unit,
    numberInputMultiplier = 1,
    numberInputFormat,
    onDrag,
    onRelease,
  } = props;

  return (
    <Stack fill ml="-3em">
      <Stack.Item grow>
        <Slider
          length="100%"
          crossLength="1.5em"
          markerPosition={invLerp(0, max, value)}
          markerColor={markerColor}
          markerOutlineColor={whiteMarkerBorder ? 'white' : 'black'}
          backgroundImage={backgroundImage}
          onDrag={useCallback((value) => onDrag(lerp(0, max, value)), [onDrag])}
          onRelease={useCallback(
            (value) => onRelease(lerp(0, max, value)),
            [onRelease],
          )}
        />
      </Stack.Item>
      <Stack.Item>
        <NumberInput
          width="5em"
          minValue={0}
          maxValue={max * numberInputMultiplier}
          step={1}
          onChange={(value) => {
            onRelease(value / numberInputMultiplier);
          }}
          value={value * numberInputMultiplier}
          format={numberInputFormat}
          unit={unit}
        />
      </Stack.Item>
    </Stack>
  );
};

type ColorPickerCallback = (color: EditorColor) => void;

export type ColorPickerProps = {
  initialColor: EditorColor;
  onSelectColor: ColorPickerCallback;
  hslWidth: string | BooleanLike;
  colorMode?: SpriteEditorColorMode;
} & Partial<BooleanStyleMap & StringStyleMap & InlineStyle>;

export const ColorPicker = (props: ColorPickerProps) => {
  const {
    initialColor,
    onSelectColor,
    hslWidth,
    colorMode = SpriteEditorColorMode.Rgba,
    ...rest
  } = props;
  const [color, setColor] = useState<EditorColor | null>(null);
  const {
    r,
    g,
    b,
    h = 0,
    s = 0,
    v,
    a = 1,
  } = asBothSpaces(color ?? initialColor);
  const alpha = colorMode === SpriteEditorColorMode.Rgba;
  switch (colorMode) {
    case SpriteEditorColorMode.Rgba:
    case SpriteEditorColorMode.Rgb:
      return (
        <Section {...rest}>
          <Stack fill height={`calc(100% - 1.33em)`} ml="0.33em" mr="0.33em">
            <Stack.Item width={hslWidth}>
              <Stack height="100%" vertical>
                <Stack.Item grow />
                <Stack.Item>
                  <SatValPad
                    hue={h}
                    saturation={s}
                    value={v}
                    width="100%"
                    onDrag={(x, y) => setColor({ h, s: x, v: 1 - y, a })}
                    onRelease={(x, y) => {
                      setColor(null);
                      onSelectColor({ h, s: x, v: 1 - y, a });
                    }}
                  />
                </Stack.Item>
                <Stack.Item mt="1em">
                  <Slider
                    length="100%"
                    crossLength="1.5em"
                    markerPosition={h / 360}
                    markerColor={hsva2hslString({ h, s: 1, v: 1, a: 1 })}
                    backgroundImage="linear-gradient(to right in hsl longer hue, red, red)"
                    onDrag={(value) =>
                      setColor({ h: Math.round(value * 360), s, v, a })
                    }
                    onRelease={(value) => {
                      setColor(null);
                      onSelectColor({ h: Math.round(value * 360), s, v, a });
                    }}
                  />
                </Stack.Item>
                <Stack.Item grow />
              </Stack>
            </Stack.Item>
            <Stack.Item grow ml="1em">
              <LabeledList>
                <LabeledList.Item verticalAlign="middle" label="Hex">
                  <Input
                    fluid
                    value={rgb2hexstring({ r, g, b, a }, false)}
                    maxLength={alpha ? 9 : 7}
                    onChange={(value) => {
                      if (!value.startsWith('#') || value.length < 7) return;
                      onSelectColor(parseHexColorString(value));
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Divider />
                <LabeledList.Item verticalAlign="middle" label="H">
                  <PickerComponentRow
                    markerColor={hsva2hslString({ h, s: 1, v: 1, a: 1 })}
                    backgroundImage="linear-gradient(to right in hsl longer hue, red, red)"
                    value={h}
                    max={360}
                    unit="°"
                    numberInputFormat={(value) => `${Math.round(value)}`}
                    onDrag={(value) => setColor({ h: value, s, v, a })}
                    onRelease={(value) => {
                      setColor(null);
                      onSelectColor({ h: value, s, v, a });
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Item verticalAlign="middle" label="S">
                  <PickerComponentRow
                    markerColor={hsva2hslString({ h, s, v: 1, a: 1 })}
                    backgroundImage={`linear-gradient(to right, ${hsva2hslString({ h, s: 0, v: 1 })}, ${hsva2hslString({ h, s: 1, v: 1 })})`}
                    value={s}
                    max={1}
                    numberInputMultiplier={100}
                    unit="%"
                    numberInputFormat={(value) =>
                      `${Math.round(value * 10) / 10}`
                    }
                    onDrag={(value) => setColor({ h, s: value, v, a })}
                    onRelease={(value) => {
                      setColor(null);
                      onSelectColor({ h, s: value, v, a });
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Item verticalAlign="middle" label="V">
                  <PickerComponentRow
                    markerColor={hsva2hslString({ h, s, v, a: 1 })}
                    whiteMarkerBorder={v < 0.5}
                    backgroundImage={`linear-gradient(to right, ${hsva2hslString({ h, s, v: 0 })}, ${hsva2hslString({ h, s, v: 1 })})`}
                    value={v}
                    max={1}
                    numberInputMultiplier={100}
                    unit="%"
                    numberInputFormat={(value) =>
                      `${Math.round(value * 10) / 10}`
                    }
                    onDrag={(value) => setColor({ h, s, v: value, a })}
                    onRelease={(value) => {
                      setColor(null);
                      onSelectColor({ h, s, v: value, a });
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Divider />
                <LabeledList.Item verticalAlign="middle" label="R">
                  <PickerComponentRow
                    markerColor={`rgb(${r}, 0, 0)`}
                    whiteMarkerBorder={r < 128}
                    backgroundImage="linear-gradient(to right, black, rgb(255, 0, 0))"
                    value={r}
                    max={255}
                    onDrag={(value) =>
                      setColor({ r: Math.round(value), g, b, a })
                    }
                    onRelease={(value) => {
                      setColor(null);
                      onSelectColor({ r: Math.round(value), g, b, a });
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Item verticalAlign="middle" label="G">
                  <PickerComponentRow
                    markerColor={`rgb(0, ${g}, 0)`}
                    whiteMarkerBorder={g < 128}
                    backgroundImage="linear-gradient(to right, black, rgb(0, 255, 0))"
                    value={g}
                    max={255}
                    onDrag={(value) =>
                      setColor({ r, g: Math.round(value), b, a })
                    }
                    onRelease={(value) => {
                      setColor(null);
                      onSelectColor({ r, g: Math.round(value), b, a });
                    }}
                  />
                </LabeledList.Item>
                <LabeledList.Item verticalAlign="middle" label="B">
                  <PickerComponentRow
                    markerColor={`rgb( 0, 0, ${b})`}
                    whiteMarkerBorder={b < 128}
                    backgroundImage="linear-gradient(to right, black, rgb(0, 0, 255))"
                    value={b}
                    max={255}
                    onDrag={(value) =>
                      setColor({ r, g, b: Math.round(value), a })
                    }
                    onRelease={(value) => {
                      setColor(null);
                      onSelectColor({ r, g, b: Math.round(value), a });
                    }}
                  />
                </LabeledList.Item>
                {alpha && (
                  <>
                    <LabeledList.Divider />
                    <LabeledList.Item verticalAlign="middle" label="A">
                      <PickerComponentRow
                        markerColor={`rgba(${r}, ${g}, ${b}, ${a})`}
                        whiteMarkerBorder={Math.max(v, 1 - a) < 0.5}
                        backgroundImage={`linear-gradient(to right, rgba(${r}, ${g}, ${b}, 0), rgba(${r}, ${g}, ${b}, 1)), url(${transparency_checkerboard})`}
                        value={a}
                        max={1}
                        numberInputMultiplier={255}
                        onDrag={(value) =>
                          setColor({
                            ...(color ?? initialColor),
                            a: value,
                          })
                        }
                        onRelease={(value) => {
                          setColor(null);
                          onSelectColor({
                            ...(color ?? initialColor),
                            a: value,
                          });
                        }}
                      />
                    </LabeledList.Item>
                  </>
                )}
              </LabeledList>
            </Stack.Item>
          </Stack>
        </Section>
      );
    case SpriteEditorColorMode.Greyscale:
      return (
        <Section {...rest}>
          <LabeledList>
            <LabeledList.Item verticalAlign="middle" label="V">
              <PickerComponentRow
                markerColor={hsva2hslString({ h, s, v, a: 1 })}
                whiteMarkerBorder={v < 0.5}
                backgroundImage={`linear-gradient(to right, ${hsva2hslString({ h, s, v: 0 })}, ${hsva2hslString({ h, s, v: 1 })})`}
                value={v}
                max={100}
                unit="%"
                onDrag={(value) => setColor({ h, s, v: value, a })}
                onRelease={(value) => {
                  setColor(null);
                  onSelectColor({ h, s, v: value, a });
                }}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      );
  }
};
