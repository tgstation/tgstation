import {
  createContext,
  type PropsWithChildren,
  useCallback,
  useContext,
  useEffect,
  useState,
} from 'react';
import { Box, Button, Popper, Stack } from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../../backend';
import {
  AdvancedCanvas,
  type AdvancedCanvasPropsBase,
} from './Components/AdvancedCanvas';
import { ColorPicker, type ColorPickerProps } from './Components/ColorPicker';
import {
  LayerManager,
  type LayerManagerProps,
} from './Components/LayerManager';
import { Palette, type PaletteProps } from './Components/Palette';
import {
  colorsAreEqual,
  colorToHexString,
  parseHexColorString,
} from './colorSpaces';
import { getFlattenedSpriteDir, localizeCoords } from './helpers';
import type { Tool } from './Types/Tool';
import { Bucket } from './Types/Tools/Bucket';
import { Eraser } from './Types/Tools/Eraser';
import { Eyedropper } from './Types/Tools/Eyedropper';
import { Pencil } from './Types/Tools/Pencil';
import {
  Dir,
  type EditorColor,
  type IncludeOrOmitEntireType,
  type SpriteData,
  type SpriteEditorContextType,
  SpriteEditorToolFlags,
  type StringLayer,
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

const undoRedoFactory = (type: TransactionType) => {
  return (props: { stack: string[] }) => {
    const { stack } = props;
    const { act } = useBackend();
    const [historyOpen, setHistoryOpen] = useState(false);
    const stackEmpty = stack.length < 1;
    const action = (count: number = 1) =>
      act(`spriteEditorCommand`, { command: type, count });
    return (
      <Popper
        isOpen={historyOpen}
        onClickOutside={() => setHistoryOpen(false)}
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
      </Popper>
    );
  };
};

const SpriteEditorContextObject = createContext<SpriteEditorContextType | null>(
  null,
);

const useSpriteEditorContext = (name: string): SpriteEditorContextType => {
  const context = useContext(SpriteEditorContextObject);
  if (!context) {
    throw new Error(`${name} must be a child of SpriteEditor.Root`);
  }
  return context;
};

const colorPicker = (
  props: Omit<ColorPickerProps, 'initialColor' | 'onSelectColor'>,
) => {
  const { currentColor, setCurrentColor } = useSpriteEditorContext(
    'SpriteEditor.ColorPicker',
  );
  return (
    <ColorPicker
      initialColor={currentColor}
      onSelectColor={setCurrentColor}
      {...props}
    />
  );
};

type ServerColorProps = {
  serverPalette: string[];
  maxServerColors: number;
  onAddServerColor: string;
  onRemoveServerColor: string;
};

type ContextPaletteProps = IncludeOrOmitEntireType<
  ServerColorProps,
  Omit<
    PaletteProps,
    | 'colors'
    | 'selectedColor'
    | 'onClickColor'
    | 'onClickAddColor'
    | 'onRemoveColor'
    | 'canAddColor'
  >
>;

function HasServerColorProps(
  props: ContextPaletteProps,
): props is ContextPaletteProps & ServerColorProps {
  return Object.hasOwn(props, 'serverPalette');
}

const palette = (props: ContextPaletteProps) => {
  const { colors, setColors, currentColor, setCurrentColor } =
    useSpriteEditorContext('SpriteEditor.Palette');
  const {
    serverPalette,
    maxServerColors,
    onAddServerColor,
    onRemoveServerColor,
  } = HasServerColorProps(props) ? props : {};
  const { act } = useBackend();
  const parsedServerColors = serverPalette?.map(parseHexColorString);
  if (parsedServerColors?.length) {
    useEffect(() => {
      if (
        !parsedServerColors.find((serverColor) =>
          colorsAreEqual(serverColor, currentColor),
        )
      ) {
        setCurrentColor(parsedServerColors[0]);
      }
    }, [JSON.stringify(parsedServerColors)]);
  }
  return (
    <Palette
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

const undoButton = undoRedoFactory('undo');
const redoButton = undoRedoFactory('redo');

const toolbar = (props: ToolbarProps) => {
  const { tools, currentTool, setCurrentTool } = useSpriteEditorContext(
    'SpriteEditor.Toolbar',
  );
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
      {tools.map((tool, i) =>
        toolFlags & (1 << i) ? (
          <Stack.Item key={i}>
            <Button
              icon={tool.icon}
              selected={currentTool === tool}
              onClick={() => setCurrentTool(tool)}
              {...toolButtonProps}
              {...perButtonProps?.(tool, i)}
            />
          </Stack.Item>
        ) : undefined,
      )}
    </Stack>
  );
};

type ContextCanvasProps = {
  data: SpriteData;
  disabled?: BooleanLike;
} & Omit<AdvancedCanvasPropsBase, 'data' | 'backdropColor'>;

const canvas = (props: ContextCanvasProps) => {
  const { data, disabled, ...rest } = props;
  const { width, height, backdrop } = data;
  const context = useSpriteEditorContext('SpriteEditor.Canvas');
  const { currentTool, selectedDir, selectedLayer, previewLayer, previewData } =
    context;
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
                !currentTool.onMouseDown(context, data, x, y, ev.button === 2)
              ) {
                ev.preventDefault();
              }
            },
            onMouseMove: (ev, ref) => {
              const [x, y] = localizeCoords(ev, ref, width, height);
              currentTool.onMouseMove?.(context, data, x, y);
            },
            onMouseUp: (ev, ref) => {
              const [x, y] = localizeCoords(ev, ref, width, height);
              currentTool.onMouseUp?.(context, data, x, y);
            },
          })}
      {...rest}
    />
  );
};

const layerManager = (props: Omit<LayerManagerProps, 'context'>) => (
  <LayerManager
    {...props}
    context={useSpriteEditorContext('SpriteEditor.LayerManager')}
  />
);

const getSpriteEditorContext = (
  serverSelectedColor?: string,
  onSelectServerColor?: string,
) => {
  const [colors, setColors] = useState<EditorColor[]>([]);
  const [currentColor, setCurrentColorInternal] = useState<EditorColor>({
    r: 255,
    g: 255,
    b: 255,
  });
  const [tools] = useState<Tool[]>(() => [
    new Pencil(),
    new Eraser(),
    new Eyedropper(),
    new Bucket(),
  ]);
  const [currentTool, setCurrentTool] = useState(tools[0]);
  const [selectedDir, setSelectedDir] = useState(Dir.SOUTH);
  const [selectedLayer, setSelectedLayer] = useState(0);
  const [previewLayer, setPreviewLayer] = useState<number>();
  const [previewData, setPreviewData] = useState<StringLayer>();
  useEffect(() => {
    if (serverSelectedColor) {
      const parsedColor = parseHexColorString(serverSelectedColor);
      if (!colorsAreEqual(parsedColor, currentColor)) {
        setCurrentColorInternal(parsedColor);
      }
    }
  }, [serverSelectedColor]);
  const { act } = useBackend();
  return {
    colors,
    setColors,
    currentColor,
    setCurrentColor: useCallback(
      (color) => {
        if (onSelectServerColor) {
          act(onSelectServerColor, { color: colorToHexString(color) });
        }
        setCurrentColorInternal(color);
      },
      [onSelectServerColor, setCurrentColorInternal, act],
    ),
    tools,
    currentTool,
    setCurrentTool,
    selectedDir,
    setSelectedDir,
    selectedLayer,
    setSelectedLayer,
    previewLayer,
    setPreviewLayer,
    previewData,
    setPreviewData,
  };
};

export namespace SpriteEditorContext {
  export const Root = (
    props: PropsWithChildren<{
      serverSelectedColor?: string;
      onSelectServerColor?: string;
    }>,
  ) => {
    const { children, serverSelectedColor, onSelectServerColor } = props;
    return (
      <SpriteEditorContextObject.Provider
        value={getSpriteEditorContext(serverSelectedColor, onSelectServerColor)}
      >
        {children}
      </SpriteEditorContextObject.Provider>
    );
  };
  export const ColorPicker = colorPicker;
  export const Palette = palette;
  export const Undo = undoButton;
  export const Redo = redoButton;
  export const Toolbar = toolbar;
  export const Canvas = canvas;
  export const LayerManager = layerManager;
}
