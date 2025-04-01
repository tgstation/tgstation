import { ReactNode, useCallback, useRef, useState } from 'react';
import {
  Box,
  Input,
  LabeledList,
  NumberInput,
  Section,
  Stack,
} from 'tgui-core/components';
import { clamp01 } from 'tgui-core/math';
import { BooleanLike } from 'tgui-core/react';
import { BooleanStyleMap, computeBoxProps, StringStyleMap } from 'tgui-core/ui';

import transparency_checkerboard from '../../../assets/transparency_checkerboard.svg';
import { AsBothSpaces, hsva2hslString, rgb2hexstring } from '../colorSpaces';
import { useClickAndDragEventHandler, useDimensions } from '../helpers';
import { EditorColor } from '../Types/types';
import { InlineStyle } from '../Types/types';

type TouchpadEventHandler = (
  event: MouseEvent,
  ref: React.RefObject<HTMLDivElement>,
) => void;

type TouchpadProps = {
  onMouseDown: TouchpadEventHandler;
  onMouseMove: TouchpadEventHandler;
  onMouseUp: TouchpadEventHandler;
  elementRef: React.RefObject<HTMLElement>;
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
  const valueOffset = `calc(${markerPosition * 100}% - 0.25rem)`;
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
  ref: React.RefObject<HTMLDivElement>,
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
            width: `${dragging ? 1.5 : 1}rem`,
            height: `${dragging ? 1.5 : 1}rem`,
            backgroundColor: hsva2hslString({
              h: hue,
              s: saturation,
              v: value,
            }),
            top: `calc(${(1 - value) * 100}% - ${dragging ? 0.75 : 0.5}rem)`,
            left: `calc(${saturation * 100}% - ${dragging ? 0.75 : 0.5}rem`,
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

type ColorPickerCallback = (color: EditorColor) => void;

type ColorSpace = 'full' | 'greyscale';

export type ColorPickerProps = {
  initialColor: EditorColor;
  onSelectColor: ColorPickerCallback;
  hslWidth: string | BooleanLike;
  space?: ColorSpace;
  alpha?: BooleanLike;
} & Partial<BooleanStyleMap & StringStyleMap & InlineStyle>;

export const ColorPicker = (props: ColorPickerProps) => {
  const {
    initialColor,
    onSelectColor,
    hslWidth,
    space = 'full',
    alpha,
    ...rest
  } = props;
  const { height } = rest;
  const [color, setColor] = useState<EditorColor | null>(null);
  const {
    r,
    g,
    b,
    h = 0,
    s = 0,
    v,
    a = 1,
  } = AsBothSpaces(color ?? initialColor);
  return (
    <Section {...rest}>
      <Stack
        fill
        height={`calc(${height} - 1.33rem)`}
        ml="0.33rem"
        mr="0.33rem"
      >
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
            <Stack.Item mt="1rem">
              <Slider
                length="100%"
                crossLength="1.5rem"
                markerPosition={h / 360}
                markerColor={hsva2hslString({ h, s: 1, v: 1, a: 1 })}
                backgroundImage="linear-gradient(to right in hsl longer hue, red, red)"
                onDrag={(value) =>
                  setColor({ h: Math.round(value * 360), s, v, a })
                }
                onRelease={(value) => {
                  setColor(null);
                  onSelectColor({ h: value * 360, s, v, a });
                }}
              />
            </Stack.Item>
            <Stack.Item grow />
          </Stack>
        </Stack.Item>
        <Stack.Item grow ml="1rem">
          <LabeledList>
            <LabeledList.Item verticalAlign="middle" label="Hex">
              <Input
                fluid
                value={rgb2hexstring({ r, g, b, a }, false)}
                maxLength={9}
                updateOnPropsChange
                onChange={(_, value) => {
                  const stripped = value.startsWith('#')
                    ? value.substring(1)
                    : value;
                  const r = parseInt(stripped.substring(0, 2), 16);
                  const g = parseInt(stripped.substring(2, 4), 16);
                  const b = parseInt(stripped.substring(4, 6), 16);
                  const a = parseInt(stripped.substring(6, 8), 16);
                  if (Number.isNaN(r) || Number.isNaN(g) || Number.isNaN(b)) {
                    return;
                  }
                  setColor({ r, g, b, a: Number.isNaN(a) ? 1 : a / 255 });
                }}
              />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item verticalAlign="middle" label="H">
              <Stack fill>
                <Stack.Item grow>
                  <Slider
                    length="100%"
                    crossLength="1.5rem"
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
                <Stack.Item>
                  <NumberInput
                    width="5rem"
                    minValue={0}
                    maxValue={360}
                    step={1}
                    onDrag={(value) => setColor({ h: value, s, v, a })}
                    onChange={(value) => {
                      setColor(null);
                      onSelectColor({ h: value, s, v, a });
                    }}
                    value={h}
                    unit="°"
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item verticalAlign="middle" label="S">
              <Stack fill>
                <Stack.Item grow>
                  <Slider
                    length="100%"
                    crossLength="1.5rem"
                    markerPosition={s}
                    markerColor={hsva2hslString({ h, s, v: 1, a: 1 })}
                    backgroundImage={`linear-gradient(to right, ${hsva2hslString({ h, s: 0, v: 1 })}, ${hsva2hslString({ h, s: 1, v: 1 })})`}
                    onDrag={(value) => setColor({ h, s: value, v, a })}
                    onRelease={(value) => {
                      setColor(null);
                      onSelectColor({ h, s: value, v, a });
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <NumberInput
                    width="5rem"
                    minValue={0}
                    maxValue={100}
                    step={1}
                    onDrag={(value) => setColor({ h, s: value / 100, v, a })}
                    onChange={(value) => {
                      setColor(null);
                      onSelectColor({ h, s: value / 100, v, a });
                    }}
                    value={Math.round(s * 1000) / 10}
                    unit="%"
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item verticalAlign="middle" label="V">
              <Stack fill>
                <Stack.Item grow>
                  <Slider
                    length="100%"
                    crossLength="1.5rem"
                    markerPosition={v}
                    markerColor={hsva2hslString({ h, s, v, a: 1 })}
                    markerOutlineColor={v > 0.5 ? 'black' : 'white'}
                    backgroundImage={`linear-gradient(to right, ${hsva2hslString({ h, s, v: 0 })}, ${hsva2hslString({ h, s, v: 1 })})`}
                    onDrag={(value) => setColor({ h, s, v: value, a })}
                    onRelease={(value) => {
                      setColor(null);
                      onSelectColor({ h, s, v: value, a });
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <NumberInput
                    width="5rem"
                    minValue={0}
                    maxValue={100}
                    step={1}
                    onDrag={(value) => setColor({ h, s, v: value / 100, a })}
                    onChange={(value) => {
                      setColor(null);
                      onSelectColor({ h, s, v: value / 100, a });
                    }}
                    value={Math.round(v * 1000) / 10}
                    unit="%"
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item verticalAlign="middle" label="R">
              <Stack fill>
                <Stack.Item grow>
                  <Slider
                    length="100%"
                    crossLength="1.5rem"
                    markerPosition={r / 255}
                    markerColor={`rgb(${r}, 0, 0)`}
                    markerOutlineColor={r > 128 ? 'black' : 'white'}
                    backgroundImage="linear-gradient(to right, black, rgb(255, 0, 0))"
                    onDrag={(value) =>
                      setColor({ r: Math.round(value * 255), g, b, a })
                    }
                    onRelease={(value) => {
                      setColor(null);
                      onSelectColor({ r: Math.round(value * 255), g, b, a });
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <NumberInput
                    width="3.3rem"
                    minValue={0}
                    maxValue={255}
                    step={1}
                    onDrag={(value) => setColor({ r: value, g, b, a })}
                    onChange={(value) => {
                      setColor(null);
                      onSelectColor({ r: value, g, b, a });
                    }}
                    value={r}
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item verticalAlign="middle" label="G">
              <Stack fill>
                <Stack.Item grow>
                  <Slider
                    length="100%"
                    crossLength="1.5rem"
                    markerPosition={g / 255}
                    markerColor={`rgb(0, ${g}, 0)`}
                    markerOutlineColor={g > 128 ? 'black' : 'white'}
                    backgroundImage="linear-gradient(to right, black, rgb(0, 255, 0))"
                    onDrag={(value) =>
                      setColor({ r, g: Math.round(value * 255), b, a })
                    }
                    onRelease={(value) => {
                      setColor(null);
                      onSelectColor({ r, g: Math.round(value * 255), b, a });
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <NumberInput
                    width="3.3rem"
                    minValue={0}
                    maxValue={255}
                    step={1}
                    onDrag={(value) => setColor({ r, g: value, b, a })}
                    onChange={(value) => {
                      setColor(null);
                      onSelectColor({ r, g: value, b, a });
                    }}
                    value={g}
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            <LabeledList.Item verticalAlign="middle" label="B">
              <Stack fill>
                <Stack.Item grow>
                  <Slider
                    length="100%"
                    crossLength="1.5rem"
                    markerPosition={b / 255}
                    markerColor={`rgb(0, 0, ${b})`}
                    markerOutlineColor={b > 128 ? 'black' : 'white'}
                    backgroundImage="linear-gradient(to right, black, rgb(0, 0, 255))"
                    onDrag={(value) =>
                      setColor({ r, g, b: Math.round(value * 255), a })
                    }
                    onRelease={(value) => {
                      setColor(null);
                      onSelectColor({ r, g, b: Math.round(value * 255), a });
                    }}
                  />
                </Stack.Item>
                <Stack.Item>
                  <NumberInput
                    width="3.3rem"
                    minValue={0}
                    maxValue={255}
                    step={1}
                    onDrag={(value) => setColor({ r, g, b: value, a })}
                    onChange={(value) => {
                      setColor(null);
                      onSelectColor({ r, g, b: value, a });
                    }}
                    value={b}
                  />
                </Stack.Item>
              </Stack>
            </LabeledList.Item>
            {alpha && (
              <>
                <LabeledList.Divider />
                <LabeledList.Item verticalAlign="middle" label="A">
                  <Stack fill>
                    <Stack.Item grow>
                      <Slider
                        length="100%"
                        crossLength="1.5rem"
                        markerPosition={a}
                        markerColor={`rgba(${r}, ${g}, ${b}, ${a})`}
                        markerOutlineColor={
                          Math.max(v, 1 - a) > 0.5 ? 'black' : 'white'
                        }
                        backgroundImage={`linear-gradient(to right, rgba(${r}, ${g}, ${b}, 0), rgba(${r}, ${g}, ${b}, 1)), url(${transparency_checkerboard})`}
                        onDrag={(value) =>
                          setColor({ ...(color ?? initialColor), a: value })
                        }
                        onRelease={(value) => {
                          setColor(null);
                          onSelectColor({
                            ...(color ?? initialColor),
                            a: value,
                          });
                        }}
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <NumberInput
                        width="3.3rem"
                        minValue={0}
                        maxValue={255}
                        step={1}
                        onDrag={(value) =>
                          setColor({
                            ...(color ?? { r: 0, g: 0, b: 0 }),
                            a: value / 255,
                          })
                        }
                        onChange={(value) => {
                          setColor(null);
                          onSelectColor({
                            ...(color ?? { r: 0, g: 0, b: 0 }),
                            a: value / 255,
                          });
                        }}
                        value={Math.round((a ?? 1) * 255)}
                      />
                    </Stack.Item>
                  </Stack>
                </LabeledList.Item>
              </>
            )}
          </LabeledList>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
