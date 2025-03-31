import { useLayoutEffect, useRef } from 'react';
import { BooleanStyleMap, computeBoxProps, StringStyleMap } from 'tgui-core/ui';

import transparency_checkerboard from '../../../assets/transparency_checkerboard.svg';
import { colorToCssString } from '../colorSpaces';
import { useClickAndDragEventHandler, useDimensions } from '../helpers';
import {
  BorderStyleProps,
  EditorColor,
  Layer,
  StringLayer,
} from '../Types/types';

type AdvancedCanvasMouseEventHandler = (
  event: MouseEvent,
  ref: React.RefObject<HTMLCanvasElement>,
) => void;

type AdvancedCanvasNoHandlers = {};
type AdvancedCanvasClickHandler = {
  onClick: AdvancedCanvasMouseEventHandler;
};
type AdvancedCanvasClickAndDragHandlers = Partial<{
  onMouseDown: AdvancedCanvasMouseEventHandler;
  onMouseMove: AdvancedCanvasMouseEventHandler;
  onMouseUp: AdvancedCanvasMouseEventHandler;
}>;

type AdvancedCanvasEventHandlers =
  | AdvancedCanvasNoHandlers
  | AdvancedCanvasClickHandler
  | AdvancedCanvasClickAndDragHandlers;

export type AdvancedCanvasPropsBase = {
  data: Layer | StringLayer;
  showGrid?: boolean;
  border?: BorderStyleProps;
  background?: string | string[];
} & Partial<BooleanStyleMap & StringStyleMap>;

type AdvancedCanvasProps = AdvancedCanvasPropsBase &
  AdvancedCanvasEventHandlers;

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
    ...rest
  } = extractBaseProps(props);
  const { onClick } = propsHaveClickHandler(props) ? props : {};
  const imageHeight = data.length;
  const imageWidth = data.at(0)?.length ?? 0;
  const parentRef = useRef<HTMLDivElement>(null);
  const canvasRef = useRef<HTMLCanvasElement>(null);
  const parentDimensions = useDimensions(parentRef);
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
    const canvas = canvasRef.current;
    if (parent === null || canvas === null) {
      return;
    }
    const [parentWidth, parentHeight] = parentDimensions;
    const scalingFactor = Math.floor(
      Math.min(parentWidth / imageWidth, parentHeight / imageHeight),
    );
    const canvasWidth = (canvas.width = imageWidth * scalingFactor);
    const canvasHeight = (canvas.height = imageHeight * scalingFactor);
    const context = canvas.getContext('2d')!;
    data.forEach((row: string[] | EditorColor[], y) =>
      row.forEach((pixel: string | EditorColor, x) => {
        context.fillStyle =
          typeof pixel === 'string' ? pixel : colorToCssString(pixel);
        context.fillRect(
          x * scalingFactor,
          y * scalingFactor,
          scalingFactor,
          scalingFactor,
        );
      }),
    );
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
  }, [parentDimensions, canvasRef, showGrid]);
  return (
    <div
      ref={parentRef}
      {...computeBoxProps({
        ...rest,
        inline: true,
        align: 'center',
        verticalAlign: 'center',
      })}
    >
      <canvas
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
          ].join(', '),
          outline: '2px solid black',
          ...borderProps,
        }}
      />
    </div>
  );
};
