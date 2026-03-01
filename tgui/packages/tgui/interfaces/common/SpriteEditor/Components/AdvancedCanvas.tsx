import { useLayoutEffect, useRef, useState } from 'react';
import transparency_checkerboard from 'tgui/assets/transparency_checkerboard.svg';
import {
  type BooleanStyleMap,
  computeBoxProps,
  type StringStyleMap,
} from 'tgui-core/ui';
import { colorToCssString } from '../colorSpaces';
import { useClickAndDragEventHandler, useDimensions } from '../helpers';
import type {
  BorderStyleProps,
  EditorColor,
  IncludeOrOmitEntireType,
  InlineStyle,
  Layer,
  StringLayer,
} from '../Types/types';

type AdvancedCanvasMouseEventHandler = (
  event: MouseEvent,
  ref: React.RefObject<HTMLCanvasElement | null>,
) => void;

type AdvancedCanvasClickHandler = {
  onClick: AdvancedCanvasMouseEventHandler;
};
type AdvancedCanvasClickAndDragHandlers = Partial<{
  onMouseDown: AdvancedCanvasMouseEventHandler;
  onMouseMove: AdvancedCanvasMouseEventHandler;
  onMouseUp: AdvancedCanvasMouseEventHandler;
}>;

type AdvancedCanvasEventHandlers =
  | AdvancedCanvasClickHandler
  | AdvancedCanvasClickAndDragHandlers;

export type AdvancedCanvasPropsBase = {
  data: Layer | StringLayer;
  showGrid?: boolean;
  border?: BorderStyleProps;
  background?: string | string[];
  backdropColor?: string;
} & Partial<BooleanStyleMap & StringStyleMap & InlineStyle>;

type AdvancedCanvasProps = IncludeOrOmitEntireType<
  AdvancedCanvasEventHandlers,
  AdvancedCanvasPropsBase
>;

const propsHaveClickHandler = (
  props: AdvancedCanvasProps,
): props is AdvancedCanvasPropsBase & AdvancedCanvasClickHandler =>
  Object.keys(props).includes('onClick');
const propsHaveClickAndDragHandlers = (
  props: AdvancedCanvasProps,
): props is AdvancedCanvasPropsBase & AdvancedCanvasClickAndDragHandlers => {
  const keys = Object.keys(props);
  return keys.includes('onMouseMove') || keys.includes('onMouseUp');
};

const extractBaseProps = (props: AdvancedCanvasProps) => {
  switch (true) {
    case propsHaveClickHandler(props): {
      const { onClick, ...rest } = props;
      return { ...rest };
    }
    case propsHaveClickAndDragHandlers(props): {
      const { onMouseDown, onMouseMove, onMouseUp, ...rest } = props;
      return { ...rest };
    }
    default:
      return props;
  }
};

export const AdvancedCanvas = (props: AdvancedCanvasProps) => {
  const {
    data,
    showGrid,
    border: borderProps,
    background,
    backdropColor,
    ...rest
  } = extractBaseProps(props);
  const { onClick } = propsHaveClickHandler(props) ? props : {};
  const imageHeight = data.length;
  const imageWidth = data.at(0)?.length ?? 0;
  const parentRef = useRef<HTMLDivElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const [parentWidth, parentHeight] = useDimensions(parentRef);
  const [[canvasWidth, canvasHeight], setCanvasDimensions] = useState<
    [number, number]
  >([0, 0]);
  const mouseDownHandler = propsHaveClickAndDragHandlers(props)
    ? useClickAndDragEventHandler(
        canvasRef,
        props.onMouseDown,
        props.onMouseMove,
        props.onMouseUp,
      )
    : undefined;
  useLayoutEffect(() => {
    const parent = parentRef.current;
    if (!parent) return;
    const { width: parentWidth, height: parentHeight } =
      parent.getBoundingClientRect();
    const scalingFactor = Math.floor(
      Math.min(parentWidth / imageWidth, parentHeight / imageHeight),
    );
    setCanvasDimensions([
      imageWidth * scalingFactor,
      imageHeight * scalingFactor,
    ]);
  }, [imageWidth, imageHeight, parentWidth, parentHeight, parentRef]);
  useLayoutEffect(() => {
    const canvas = canvasRef.current;
    if (!canvas) {
      return;
    }
    const scalingFactor = canvasWidth / imageWidth;
    const context = canvas.getContext('2d')!;
    if (backdropColor) {
      context.fillStyle = backdropColor;
      context.fillRect(0, 0, canvasWidth, canvasHeight);
    }
    data.forEach((row: string[] | EditorColor[], y) => {
      row.forEach((pixel: string | EditorColor, x) => {
        context.fillStyle =
          typeof pixel === 'string' ? pixel : colorToCssString(pixel);
        context.fillRect(
          x * scalingFactor,
          y * scalingFactor,
          scalingFactor,
          scalingFactor,
        );
      });
    });
    if (showGrid && scalingFactor >= 5) {
      context.beginPath();
      context.strokeStyle = 'black';
      context.lineWidth = 2;
      for (let y = 0; y <= canvasHeight; y += scalingFactor) {
        context.moveTo(0, y);
        context.lineTo(canvasWidth, y);
      }
      for (let x = 0; x <= canvasWidth; x += scalingFactor) {
        context.moveTo(x, 0);
        context.lineTo(x, canvasHeight);
      }
      context.stroke();
    }
  }, [
    JSON.stringify(data),
    canvasWidth,
    canvasHeight,
    canvasRef,
    showGrid,
    backdropColor,
  ]);
  return (
    <div
      ref={parentRef}
      {...computeBoxProps({
        ...rest,
        inline: true,
        align: 'center',
        verticalAlign: 'middle',
      })}
    >
      <canvas
        width={canvasWidth}
        height={canvasHeight}
        ref={canvasRef}
        onClick={onClick && ((ev) => onClick(ev.nativeEvent, canvasRef))}
        onMouseDown={mouseDownHandler}
        style={{
          backgroundImage: [
            ...(Array.isArray(background)
              ? background
              : background
                ? [background]
                : []),
            `url(${transparency_checkerboard})`,
          ].join(','),
          outline: '2px solid black',
          ...borderProps,
        }}
      />
    </div>
  );
};
