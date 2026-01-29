import { useAtom, useAtomValue, useSetAtom } from 'jotai';
import { useEffect, useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Floating, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalize } from 'tgui-core/string';
import {
  colorsAtom,
  currentColorAtom,
  currentColorInternalAtom,
  currentToolAtom,
  dirAtom,
  layerAtom,
  onSelectServerColorAtom,
  previewDataAtom,
  previewLayerAtom,
  tools,
} from './atoms';
import {
  AdvancedCanvas,
  type AdvancedCanvasPropsBase,
} from './Components/AdvancedCanvas';
import {
  ColorPicker as BaseColorPicker,
  type ColorPickerProps as BaseColorPickerProps,
} from './Components/ColorPicker';
import {
  LayerManager as BaseLayerManager,
  type LayerManagerProps as BaseLayerManagerProps,
} from './Components/LayerManager';
import {
  Palette as BasePalette,
  type PaletteProps as BasePaletteProps,
} from './Components/Palette';
import {
  colorsAreEqual,
  colorToHexString,
  parseHexColorString,
} from './colorSpaces';
import { getFlattenedSpriteDir, localizeCoords } from './helpers';
import type { Tool } from './Types/Tool';
import {
  type IncludeOrOmitEntireType,
  type SpriteData,
  SpriteEditorToolFlags,
} from './Types/types';

type ToolbarButtonProps = Omit<
  Parameters<typeof Button>[0],
  'icon' | 'onClick' | 'selected' | 'ellipsis'
>;

type ToolbarProps = {
  toolButtonProps?: ToolbarButtonProps;
  perButtonProps?: (tool: Tool, i: number) => ToolbarButtonProps;
  toolFlags?: SpriteEditorToolFlags;
} & Parameters<typeof Stack>[0];

type TransactionType = 'undo' | 'redo';

type HistoryButtonProps = {
  stack: string[];
  type: TransactionType;
};

const HistoryButton = (props: HistoryButtonProps) => {
  const { stack, type } = props;
  const { act } = useBackend();
  const [historyOpen, setHistoryOpen] = useState(false);
  const stackEmpty = stack.length < 1;
  const action = (count = 1) =>
    act(`spriteEditorCommand`, { command: type, count });
  return (
    <Floating
      handleOpen={historyOpen}
      content={
        <Box backgroundColor="rgba(0, 0, 0, 33%)">
          <Stack vertical maxHeight="15rem" overflowY="scroll">
            {stack.map((transaction, i) => (
              <Stack.Item key={i} m={0}>
                <Button
                  mx="0.5rem"
                  color="transparent"
                  width="100%"
                  ellipsis
                  onClick={() => {
                    action(i);
                    setHistoryOpen(false);
                  }}
                >
                  {transaction}
                </Button>
              </Stack.Item>
            ))}
          </Stack>
        </Box>
      }
    >
      <Button
        inline
        mr={0}
        icon={type}
        disabled={stackEmpty}
        tooltip={`${capitalize(type)}${stackEmpty ? '' : ` ${stack[stack.length - 1]}`}`}
        onClick={() => action()}
        style={{
          borderTopRightRadius: 0,
          borderBottomRightRadius: 0,
          borderRight: '1px solid rgba(255, 255, 255, 0.33)',
        }}
      />
      <Button
        inline
        ml={0}
        icon={historyOpen ? 'chevron-up' : 'chevron-down'}
        disabled={stackEmpty}
        iconSize={0.5}
        onClick={() => setHistoryOpen(!historyOpen)}
        style={{
          borderTopLeftRadius: 0,
          borderBottomLeftRadius: 0,
        }}
      />
    </Floating>
  );
};

type ServerColorProps = {
  serverPalette: string[];
  maxServerColors: number;
  onAddServerColor: string;
  onRemoveServerColor: string;
};

type PaletteProps = IncludeOrOmitEntireType<
  ServerColorProps,
  Omit<
    BasePaletteProps,
    | 'colors'
    | 'selectedColor'
    | 'onClickColor'
    | 'onClickAddColor'
    | 'onRemoveColor'
    | 'canAddColor'
  >
>;

const hasServerColorProps = (
  props: PaletteProps,
): props is PaletteProps & ServerColorProps => {
  return Object.hasOwn(props, 'serverPalette');
};

type CanvasProps = {
  data: SpriteData;
  disabled?: BooleanLike;
} & Omit<AdvancedCanvasPropsBase, 'data' | 'backdropColor'>;

export namespace SpriteEditor {
  export const syncBackend = (
    onSelectServerColor?: string,
    serverSelectedColor?: string,
  ) => {
    const [currentColor, setCurrentColor] = useAtom(currentColorInternalAtom);
    const setOnSelectServerColor = useSetAtom(onSelectServerColorAtom);
    useEffect(
      () => setOnSelectServerColor(onSelectServerColor),
      [onSelectServerColor],
    );
    useEffect(() => {
      if (serverSelectedColor) {
        const parsedColor = parseHexColorString(serverSelectedColor);
        if (!colorsAreEqual(parsedColor, currentColor)) {
          setCurrentColor(parsedColor);
        }
      }
    }, [serverSelectedColor]);
  };

  export const ColorPicker = (
    props: Omit<BaseColorPickerProps, 'initialColor' | 'onSelectColor'>,
  ) => {
    const [currentColor, setCurrentColor] = useAtom(currentColorAtom);
    return (
      <BaseColorPicker
        initialColor={currentColor ?? { v: 1 }}
        onSelectColor={setCurrentColor}
        {...props}
      />
    );
  };

  export const Palette = (props: PaletteProps) => {
    const [colors, setColors] = useAtom(colorsAtom);
    const [currentColor, setCurrentColor] = useAtom(currentColorAtom);
    const {
      serverPalette,
      maxServerColors,
      onAddServerColor,
      onRemoveServerColor,
    } = hasServerColorProps(props) ? props : {};
    const { act } = useBackend();
    const parsedServerColors = serverPalette?.map(parseHexColorString);
    useEffect(() => {
      if (!parsedServerColors) {
        return;
      }
      if (
        !parsedServerColors.find((serverColor) =>
          colorsAreEqual(serverColor, currentColor),
        )
      ) {
        setCurrentColor(parsedServerColors[0]);
      }
    }, [JSON.stringify(parsedServerColors)]);
    return (
      <BasePalette
        colors={parsedServerColors ?? colors}
        selectedColor={currentColor}
        onClickColor={setCurrentColor}
        onClickAddColor={() => {
          if (onAddServerColor) {
            act(onAddServerColor, { color: colorToHexString(currentColor) });
          } else {
            setColors((colors) => [...colors, currentColor]);
          }
        }}
        onRemoveColor={(index) => {
          if (onRemoveServerColor) {
            act(onRemoveServerColor, { index });
          } else {
            setColors(colors.toSpliced(index, 1));
          }
        }}
        maxColors={maxServerColors}
        {...props}
      />
    );
  };

  export const Undo = (props: Pick<HistoryButtonProps, 'stack'>) => {
    const { stack } = props;
    return <HistoryButton stack={stack} type="undo" />;
  };

  export const Redo = (props: Pick<HistoryButtonProps, 'stack'>) => {
    const { stack } = props;
    return <HistoryButton stack={stack} type="redo" />;
  };

  export const Toolbar = (props: ToolbarProps) => {
    const [currentTool, setCurrentTool] = useAtom(currentToolAtom);
    const {
      toolButtonProps,
      perButtonProps,
      toolFlags = SpriteEditorToolFlags.All,
      ...rest
    } = props;
    useEffect(() => {
      if (!(toolFlags & (1 << tools.indexOf(currentTool)))) {
        setCurrentTool(tools.find((_, i) => toolFlags & (1 << i))!);
      }
    }, [toolFlags]);
    return (
      <Stack {...rest}>
        {tools.map(
          (tool, i) =>
            !!(toolFlags & (1 << i)) && (
              <Stack.Item key={i}>
                <Button
                  icon={tool.icon}
                  selected={currentTool === tool}
                  onClick={() => setCurrentTool(tool)}
                  {...toolButtonProps}
                  {...perButtonProps?.(tool, i)}
                />
              </Stack.Item>
            ),
        )}
      </Stack>
    );
  };

  export const Canvas = (props: CanvasProps) => {
    const { data, disabled, ...rest } = props;
    const { width, height, backdrop } = data;
    const [currentColor, setCurrentColor] = useAtom(currentColorAtom);
    const currentTool = useAtomValue(currentToolAtom);
    const selectedDir = useAtomValue(dirAtom);
    const selectedLayer = useAtomValue(layerAtom);
    const [previewLayer, setPreviewLayer] = useAtom(previewLayerAtom);
    const [previewData, setPreviewData] = useAtom(previewDataAtom);
    const toolContext = {
      currentColor,
      setCurrentColor,
      selectedDir,
      selectedLayer,
      setPreviewLayer,
      setPreviewData,
    };
    useEffect(() => {
      if (disabled) {
        currentTool.cancel?.();
      }
    }, [disabled, currentTool]);
    return (
      <AdvancedCanvas
        data={getFlattenedSpriteDir(
          data,
          selectedDir,
          selectedLayer,
          previewLayer,
          previewData,
        )}
        backdropColor={backdrop}
        {...(disabled
          ? {}
          : {
              onMouseDown: (ev, ref) => {
                const [x, y] = localizeCoords(ev, ref, width, height);
                if (
                  !currentTool.onMouseDown(
                    toolContext,
                    data,
                    x,
                    y,
                    ev.button === 2,
                  )
                ) {
                  ev.preventDefault();
                }
              },
              onMouseMove: (ev, ref) => {
                const [x, y] = localizeCoords(ev, ref, width, height);
                currentTool.onMouseMove?.(toolContext, data, x, y);
              },
              onMouseUp: (ev, ref) => {
                const [x, y] = localizeCoords(ev, ref, width, height);
                currentTool.onMouseUp?.(toolContext, data, x, y);
              },
            })}
        {...rest}
      />
    );
  };

  export const LayerManager = (
    props: Omit<BaseLayerManagerProps, 'context'>,
  ) => {
    const [selectedDir, setSelectedDir] = useAtom(dirAtom);
    const [selectedLayer, setSelectedLayer] = useAtom(layerAtom);
    return (
      <BaseLayerManager
        {...props}
        selectedDir={selectedDir}
        setSelectedDir={setSelectedDir}
        selectedLayer={selectedLayer}
        setSelectedLayer={setSelectedLayer}
      />
    );
  };
}
