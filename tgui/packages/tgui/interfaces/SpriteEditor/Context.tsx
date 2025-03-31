import { createContext, ReactNode, useContext, useState } from 'react';
import { Box, Button, Popper, Stack } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import { useBackend } from '../../backend';
import {
  AdvancedCanvas,
  AdvancedCanvasPropsBase,
} from './Components/AdvancedCanvas';
import { ColorPicker, ColorPickerProps } from './Components/ColorPicker';
import { LayerManager, LayerManagerProps } from './Components/LayerManager';
import { Palette, PaletteProps } from './Components/Palette';
import { getFlattenedSpriteDir, localizeCoords } from './helpers';
import { Tool } from './Types/Tool';
import { Eraser } from './Types/Tools/Eraser';
import { Eyedropper } from './Types/Tools/Eyedropper';
import { Pencil } from './Types/Tools/Pencil';
import {
  Dir,
  EditorColor,
  SpriteData,
  SpriteEditorContextType,
  StringLayer,
} from './Types/types';

type ToolbarButtonProps = Omit<
  Parameters<typeof Button>[0],
  'icon' | 'onClick' | 'selected' | 'ellipsis'
>;

type ToolbarProps = {
  toolButtonProps?: ToolbarButtonProps;
  perButtonProps?: (tool: Tool, i: number) => ToolbarButtonProps;
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
          tooltip={`${capitalize(type)}${stackEmpty ? '' : ' ' + stack[stack.length - 1]}`}
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

const palette = (
  props: Omit<
    PaletteProps,
    'colors' | 'selectedColor' | 'onClickColor' | 'onClickAddColor'
  >,
) => {
  const { colors, setColors, currentColor, setCurrentColor } =
    useSpriteEditorContext('SpriteEditor.Palette');
  return (
    <Palette
      colors={colors}
      selectedColor={currentColor}
      onClickColor={setCurrentColor}
      onClickAddColor={() => setColors((colors) => [...colors, currentColor])}
      {...props}
    />
  );
};

const undoButton = undoRedoFactory('undo');
const redoButton = undoRedoFactory('redo');

const toolbar = (props: ToolbarProps) => {
  const { tools, currentTool, setCurrentTool } = useContext(
    SpriteEditorContextObject,
  )!;
  const { toolButtonProps, perButtonProps, ...rest } = props;
  return (
    <Stack {...rest}>
      {tools.map((tool, i) => (
        <Stack.Item key={i}>
          <Button
            icon={tool.icon}
            selected={currentTool === tool}
            onClick={() => setCurrentTool(tool)}
            {...toolButtonProps}
            {...perButtonProps?.(tool, i)}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
};

const canvas = (
  props: { data: SpriteData } & Omit<AdvancedCanvasPropsBase, 'data'>,
) => {
  const { data, ...rest } = props;
  const { width, height } = data;
  const context = useSpriteEditorContext('SpriteEditor.Canvas');
  const {
    currentTool,
    selectedDir,
    selectedLayer,
    visibleLayers,
    previewLayer,
    previewData,
  } = context;
  return (
    <AdvancedCanvas
      data={getFlattenedSpriteDir(
        data,
        selectedDir,
        visibleLayers.toSpliced(selectedLayer, 1, true),
        previewLayer,
        previewData,
      )}
      onMouseDown={(ev, ref) => {
        const [x, y] = localizeCoords(ev, ref, width, height);
        if (!currentTool.onMouseDown(context, data, x, y, ev.button === 2)) {
          ev.preventDefault();
        }
      }}
      onMouseMove={(ev, ref) => {
        const [x, y] = localizeCoords(ev, ref, width, height);
        currentTool.onMouseMove?.(context, data, x, y);
      }}
      onMouseUp={(ev, ref) => {
        const [x, y] = localizeCoords(ev, ref, width, height);
        currentTool.onMouseUp?.(context, data, x, y);
      }}
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

const getSpriteEditorContext = () => {
  const [colors, setColors] = useState<EditorColor[]>([]);
  const [currentColor, setCurrentColor] = useState<EditorColor>({
    r: 255,
    g: 255,
    b: 255,
  });
  const [tools] = useState<Tool[]>(() => [
    new Pencil(),
    new Eraser(),
    new Eyedropper(),
  ]);
  const [currentTool, setCurrentTool] = useState(tools[0]);
  const [selectedDir, setSelectedDir] = useState(Dir.SOUTH);
  const [selectedLayer, setSelectedLayer] = useState(0);
  const [visibleLayers, setVisibleLayers] = useState<boolean[]>([]);
  const [previewLayer, setPreviewLayer] = useState<number>();
  const [previewData, setPreviewData] = useState<StringLayer>();
  return {
    colors,
    setColors,
    currentColor,
    setCurrentColor,
    tools,
    currentTool,
    setCurrentTool,
    selectedDir,
    setSelectedDir,
    selectedLayer,
    setSelectedLayer,
    visibleLayers,
    setVisibleLayers,
    previewLayer,
    setPreviewLayer,
    previewData,
    setPreviewData,
  };
};

export namespace SpriteEditorContext {
  export const Root = ({ children }: { children: ReactNode }) => (
    <SpriteEditorContextObject.Provider value={getSpriteEditorContext()}>
      {children}
    </SpriteEditorContextObject.Provider>
  );
  export const ColorPicker = colorPicker;
  export const Palette = palette;
  export const Undo = undoButton;
  export const Redo = redoButton;
  export const Toolbar = toolbar;
  export const Canvas = canvas;
  export const LayerManager = layerManager;
}
