import { type PropsWithChildren, type ReactNode, useState } from 'react';
import { Box, Button, Stack } from 'tgui-core/components';
import { clamp } from 'tgui-core/math';
import type { BooleanLike } from 'tgui-core/react';
import { decodeHtmlEntities } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import { SpriteEditor } from './common/SpriteEditor';
import {
  AdvancedCanvas,
  type AdvancedCanvasPropsBase,
} from './common/SpriteEditor/Components/AdvancedCanvas';
import { hasServerColorData } from './common/SpriteEditor/helpers';
import { Dir, type SpriteEditorData } from './common/SpriteEditor/Types/types';

type CanvasMetadata = {
  title: string;
  author: string;
  patron?: string;
  medium: string;
  date?: string;
};

type CanvasData = {
  metadata: CanvasMetadata;
  editorData: SpriteEditorData;
  pixelsPerUnit: number;
  finalized: BooleanLike;
  editable: BooleanLike;
  allowColorPicker: BooleanLike;
  showPlaque: BooleanLike;
  year_offset: number;
};

type ZoomProps = {
  zoom: number;
  setZoom: React.Dispatch<React.SetStateAction<number>>;
  pixelsPerUnit: number;
};

type CanvasCommonProps = ZoomProps & {
  width: number;
  height: number;
};

const ZoomButtons = ({ zoom, setZoom, pixelsPerUnit }: ZoomProps) => (
  <Stack>
    <Stack.Item>
      <Button
        icon="search-minus"
        tooltip="Zoom Out (Shift + Scroll Down)"
        disabled={zoom <= 1}
        onClick={() => setZoom(Math.max(1, zoom - 1 / pixelsPerUnit))}
      />
    </Stack.Item>
    <Stack.Item>
      <Button
        icon="search-plus"
        tooltip="Zoom In (Shift + Scroll Up)"
        disabled={zoom >= 3}
        onClick={() => setZoom(Math.min(3, zoom + 1 / pixelsPerUnit))}
      />
    </Stack.Item>
  </Stack>
);

const ZoomListener = ({
  zoom,
  setZoom,
  pixelsPerUnit,
  children,
}: PropsWithChildren<ZoomProps>) => (
  <>
    {/* I'm too lazy to go through the process of adding onWheel to BoxProps. */}
    <div
      onMouseOver={(ev) => ev.currentTarget.focus()}
      onWheel={(ev) => {
        if (!ev.shiftKey) return;
        ev.preventDefault();
        setZoom(
          clamp(zoom + (Math.sign(-ev.deltaY) * 1) / pixelsPerUnit, 1, 3),
        );
      }}
      style={{
        width: '100%',
        height: '100%',
      }}
    >
      {children}
    </div>
  </>
);

type EditableCanvasProps = Pick<
  CanvasData,
  'editorData' | 'editable' | 'allowColorPicker'
> &
  CanvasCommonProps;

const EditableCanvas = (props: EditableCanvasProps) => {
  const { act } = useBackend();
  const {
    editorData,
    pixelsPerUnit,
    editable,
    allowColorPicker,
    zoom,
    setZoom,
    width,
    height,
  } = props;
  const { sprite, colorMode, toolFlags } = editorData;
  const usingImplement = editable && hasServerColorData(editorData);
  const {
    serverSelectedColor,
    serverPalette,
    maxServerColors,
    onSelectServerColor,
    onAddServerColor,
    onRemoveServerColor,
  } = usingImplement ? editorData : {};
  const [showGrid, setShowGrid] = useState(false);
  const sidebarItems: ReactNode[] = [];
  SpriteEditor.syncBackend(onSelectServerColor, serverSelectedColor);
  if (allowColorPicker) {
    sidebarItems.push(
      <Stack.Item width="100%">
        <SpriteEditor.ColorPicker
          width="100%"
          colorMode={colorMode}
          hslWidth="40%"
          style={{ aspectRatio: 2 }}
        />
      </Stack.Item>,
    );
  }
  if (usingImplement && maxServerColors! > 1) {
    sidebarItems.push(
      <Stack.Item grow width="100%">
        <SpriteEditor.Palette
          serverPalette={serverPalette!}
          maxServerColors={maxServerColors!}
          onAddServerColor={onAddServerColor!}
          onRemoveServerColor={onRemoveServerColor!}
          maxHeight="100%"
          overflowY="auto"
        />
      </Stack.Item>,
    );
  }
  const shouldRenderSidebar = sidebarItems.length > 0;
  return (
    <Window
      width={shouldRenderSidebar ? Math.max(width, 250) + 400 : width + 90}
      height={shouldRenderSidebar ? Math.max(height + 110, 350) : height + 110}
    >
      <Window.Content>
        <Stack fill>
          {shouldRenderSidebar && (
            <Stack.Item>
              <Stack fill vertical width="350px">
                {sidebarItems}
              </Stack>
            </Stack.Item>
          )}
          <Stack.Item grow minWidth="0">
            <Stack fill vertical>
              <Stack.Item>
                <Stack fill justify="space-around">
                  {!!editable && (
                    <>
                      <Stack.Item>
                        <SpriteEditor.Toolbar
                          toolFlags={toolFlags}
                          perButtonProps={(tool) => {
                            return { tooltip: tool.name };
                          }}
                        />
                      </Stack.Item>
                      <Stack.Item grow />
                    </>
                  )}
                  <Stack.Item>
                    <Button.Checkbox
                      checked={showGrid}
                      onClick={() => setShowGrid(!showGrid)}
                    >
                      Show Grid
                    </Button.Checkbox>
                  </Stack.Item>
                  <Stack.Item>
                    <ZoomButtons {...{ zoom, setZoom, pixelsPerUnit }} />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item grow width="100%" textAlign="center" overflow="auto">
                <ZoomListener {...{ zoom, setZoom, pixelsPerUnit }}>
                  <SpriteEditor.Canvas
                    width={`${width}px`}
                    height={`${height}px`}
                    showGrid={showGrid}
                    data={sprite}
                    disabled={!editable}
                    position="relative"
                    top="50%"
                    style={{ transform: 'translate(0, -50%)' }}
                  />
                </ZoomListener>
              </Stack.Item>
              <Stack.Item basis={0} width="100%" textAlign="center">
                <Button.Confirm onClick={() => act('finalize')}>
                  Finalize
                </Button.Confirm>
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

type FinalizedCanvasProps = { data: AdvancedCanvasPropsBase['data'] } & Pick<
  CanvasData,
  'metadata' | 'showPlaque' | 'year_offset'
> &
  CanvasCommonProps;

const FinalizedCanvas = (props: FinalizedCanvasProps) => {
  const {
    data,
    metadata,
    showPlaque,
    zoom,
    setZoom,
    pixelsPerUnit,
    width,
    height,
    year_offset,
  } = props;
  const { title, author, date, medium, patron } = metadata;
  const { act } = useBackend();
  return (
    <Window width={width + 90} height={height + (showPlaque ? 270 : 90)}>
      <Window.Content>
        <Stack fill vertical align="center">
          <Stack.Item>
            <ZoomButtons {...{ zoom, setZoom, pixelsPerUnit }} />
          </Stack.Item>
          <Stack.Item>
            <ZoomListener {...{ zoom, setZoom, pixelsPerUnit }}>
              <AdvancedCanvas
                width={`${width}px`}
                height={`${height}px`}
                data={data}
              />
            </ZoomListener>
          </Stack.Item>
          {showPlaque ? (
            <Stack.Item
              p="2em"
              width="60%"
              basis={0}
              textColor="black"
              textAlign="left"
              backgroundColor="white"
              style={{ borderStyle: 'inset' }}
            >
              <Box mb="1em" fontSize="18px" bold>
                {decodeHtmlEntities(title)}
              </Box>
              <Box bold>
                {author}
                {date && `- ${new Date(date).getFullYear() + year_offset}`}
              </Box>
              <Box italic>{medium}</Box>
              <Box italic>
                {patron && `Sponsored by ${patron}`}
                <Button
                  icon="hand-holding-usd"
                  color="transparent"
                  iconColor="black"
                  onClick={() => act('patronage')}
                />
              </Box>
            </Stack.Item>
          ) : undefined}
        </Stack>
      </Window.Content>
    </Window>
  );
};

export const Canvas = () => {
  const { data } = useBackend<CanvasData>();
  const {
    metadata,
    editorData,
    pixelsPerUnit,
    finalized,
    editable,
    allowColorPicker,
    showPlaque,
    year_offset,
  } = data;
  const { sprite } = editorData;
  const { width, height } = sprite;
  const [zoom, setZoom] = useState(finalized ? 1 : 3);
  const paintingRenderWidth = pixelsPerUnit * zoom * width;
  const paintingRenderHeight = pixelsPerUnit * zoom * height;
  if (finalized) {
    const { layers } = sprite;
    const spriteData = layers[0].data[Dir.SOUTH];
    return (
      <FinalizedCanvas
        data={spriteData}
        width={paintingRenderWidth}
        height={paintingRenderHeight}
        {...{
          metadata,
          showPlaque,
          zoom,
          setZoom,
          pixelsPerUnit,
          year_offset,
        }}
      />
    );
  } else {
    return (
      <EditableCanvas
        width={paintingRenderWidth}
        height={paintingRenderHeight}
        {...{
          editorData,
          editable,
          allowColorPicker,
          zoom,
          setZoom,
          pixelsPerUnit,
        }}
      />
    );
  }
};
