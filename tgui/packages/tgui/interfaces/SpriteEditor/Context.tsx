import { useCallback, useEffect, useState } from 'react';
import { Box, Button, Popper, Stack } from 'tgui-core/components';
import { capitalize } from 'tgui-core/string';

import {
  AdvancedCanvas,
  AdvancedCanvasPropsBase,
} from './Components/AdvancedCanvas';
import { ColorPicker, ColorPickerProps } from './Components/ColorPicker';
import { Palette, PaletteProps } from './Components/Palette';
import { localizeCoords, typedCapitalize, useStoreState } from './helpers';
import { Tool } from './Types/Tool';
import { Eraser } from './Types/Tools/Eraser';
import { Pencil } from './Types/Tools/Pencil';
import { EditorColor } from './Types/types';
import { Workspace } from './Types/Workspace';

type ToolbarButtonProps = Omit<
  Parameters<typeof Button>[0],
  'icon' | 'onClick' | 'selected' | 'ellipsis'
>;

type ToolbarProps = {
  toolButtonProps?: ToolbarButtonProps;
  perButtonProps?: (tool: Tool, i: number) => ToolbarButtonProps;
} & Parameters<typeof Stack>[0];

type TransactionType = 'undo' | 'redo';
type TransactionStoreType = `use${Capitalize<TransactionType>}Stack`;

const undoRedoFactory = (type: TransactionType) => {
  const stackStoreName: TransactionStoreType = `use${typedCapitalize(type)}Stack`;
  return (props: { workspace: Workspace }) => {
    const { workspace } = props;
    const stack = workspace[stackStoreName]();
    const [historyOpen, setHistoryOpen] = useState(false);
    const stackEmpty = stack.length < 1;
    const action = workspace[type].bind(workspace);
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
                      for (let j = 0; j <= i; j++) action();
                      setHistoryOpen(false);
                    }}
                  >
                    {transaction.name}
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
          tooltip={`${capitalize(type)}${stackEmpty ? '' : ' ' + stack[stack.length - 1].name}`}
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

export const useSpriteEditorContext = () => {
  const [tools] = useState<Tool[]>(() => [new Pencil(), new Eraser()]);
  const [useCurrentTool, setCurrentTool] = useStoreState(tools[0]);
  const [useColors, setColors] = useStoreState<EditorColor[]>([]);
  const [useCurrentColor, setCurrentColor, getCurrentColor] =
    useStoreState<EditorColor>({
      r: 255,
      g: 255,
      b: 255,
    });
  const colorPicker = useCallback(
    (props: Omit<ColorPickerProps, 'initialColor' | 'onSelectColor'>) => (
      <ColorPicker
        initialColor={useCurrentColor()}
        onSelectColor={setCurrentColor}
        {...props}
      />
    ),
    [],
  );
  const palette = useCallback(
    (
      props: Omit<
        PaletteProps,
        'colors' | 'selectedColor' | 'onClickColor' | 'onClickAddColor'
      >,
    ) => {
      const currentColor = useCurrentColor();
      return (
        <Palette
          colors={useColors()}
          selectedColor={currentColor}
          onClickColor={setCurrentColor}
          onClickAddColor={() =>
            setColors((colors) => [...colors, currentColor])
          }
          {...props}
        />
      );
    },
    [],
  );
  const undoButton = useCallback(undoRedoFactory('undo'), []);
  const redoButton = useCallback(undoRedoFactory('redo'), []);
  const toolbar = useCallback((props: ToolbarProps) => {
    const { toolButtonProps, perButtonProps, ...rest } = props;
    const currentTool = useCurrentTool();
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
  }, []);
  const canvas = useCallback(
    (
      props: { workspace: Workspace } & Omit<
        AdvancedCanvasPropsBase,
        'data' | 'showGrid'
      >,
    ) => {
      const { workspace, ...rest } = props;
      useEffect(() => {
        workspace.getPrimaryColor = getCurrentColor;
        return () => {
          workspace.getPrimaryColor = null;
        };
      }, [workspace]);
      const { icon } = workspace;
      const currentTool = useCurrentTool();
      return (
        <AdvancedCanvas
          data={workspace.useMainCanvasData()}
          onMouseDown={(ev, ref) => {
            const [x, y] = localizeCoords(ev, ref, icon);
            if (!currentTool.onMouseDown(workspace, x, y, ev.button === 2)) {
              ev.preventDefault();
            }
          }}
          onMouseMove={(ev, ref) => {
            const [x, y] = localizeCoords(ev, ref, icon);
            currentTool.onMouseMove(workspace, x, y);
          }}
          onMouseUp={(ev, ref) => {
            const [x, y] = localizeCoords(ev, ref, icon);
            currentTool.onMouseUp(workspace, x, y);
          }}
          {...rest}
        />
      );
    },
    [],
  );
  return { colorPicker, palette, undoButton, redoButton, toolbar, canvas };
};
