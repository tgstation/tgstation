import { useState } from 'react';
import { resolveAsset } from 'tgui/assets';
import { useBackend } from 'tgui/backend';
import { ByondUi, InfinitePlane } from 'tgui-core/components';
import { Window } from '../../layouts';
import { AppearanceBox } from './AppearanceBox';
import type {
  Appearance,
  AppearanceData,
  AppearanceDebugData,
  AppearanceMap,
} from './types';
import { AppearanceParentType } from './types';
import { AppearanceDebugContext } from './useAppearanceDebug';

function textWidth(text: string, font: string, fontsize: number) {
  font = `${fontsize}px ${font}`;
  const c = document.createElement('canvas');
  const ctx = c.getContext('2d') as CanvasRenderingContext2D;
  ctx.font = font;
  return ctx.measureText(text).width;
}

function mapAppearance(
  appearance_data: AppearanceData,
  parent: Appearance | null = null,
  parent_type: AppearanceParentType = AppearanceParentType.None,
  depth: number = 0,
  appearances: AppearanceMap = {},
) {
  const appearance: Appearance = {
    data: appearance_data,
    underlays: null,
    overlays: null,
    parent: parent,
    parent_type: parent_type,
    render_target_to: null,
    position: { x: 0, y: 0 },
    depth: depth,
  };
  appearances[appearance_data.id] = appearance;
  if (appearance_data.underlays.length > 0)
    appearance.underlays = appearance_data.underlays
      .map((data) =>
        mapAppearance(
          data,
          appearance,
          AppearanceParentType.Underlay,
          depth + 1,
          appearances,
        ),
      )
      .sort((a, b) =>
        a.data.plane === b.data.plane
          ? a.data.layer - b.data.layer
          : a.data.plane - b.data.plane,
      );
  if (appearance_data.overlays.length > 0)
    appearance.overlays = appearance_data.overlays
      .map((data) =>
        mapAppearance(
          data,
          appearance,
          AppearanceParentType.Overlay,
          depth + 1,
          appearances,
        ),
      )
      .sort((a, b) =>
        a.data.plane === b.data.plane
          ? a.data.layer - b.data.layer
          : a.data.plane - b.data.plane,
      );
  return appearance;
}

function getAppearanceHeight(appearance: Appearance) {
  const titlebar = appearance.data.icon_state || appearance.data.name ? 27 : 12;
  const COLUMN_BREAK = 20;
  let rows = 0;
  if (appearance.data.icon) rows++;
  if (appearance.data.icon_state) rows++;
  if (appearance.data.layer) rows++;
  if (appearance.data.plane) rows++;
  let height = COLUMN_BREAK + titlebar + rows * 15 + (rows - 1) * 6 + 12;
  if (appearance.data.embed_icon) height += 64 + 10;
  return height;
}

function parseAppearanceData(mainAppearance: AppearanceData) {
  const appearances: AppearanceMap = {};
  // Recursively map all appearances
  const primary: Appearance = mapAppearance(
    mainAppearance,
    null,
    AppearanceParentType.None,
    0,
    appearances,
  );

  const appearanceStacks: Record<number, Appearance[]> = {};
  const widthPerStack: Record<number, number> = {};
  const sourceMap: Record<string, Appearance> = {};
  Object.values(appearances).forEach((element) => {
    if (!(element.depth in appearanceStacks))
      appearanceStacks[element.depth] = [];
    appearanceStacks[element.depth].push(element);
    if (element.data.render_target)
      sourceMap[element.data.render_target] = element;
  });

  Object.values(appearances).forEach((element) => {
    if (element.data.render_source && element.data.render_source in sourceMap) {
      if (sourceMap[element.data.render_source].render_target_to === null)
        sourceMap[element.data.render_source].render_target_to = [];
      sourceMap[element.data.render_source].render_target_to?.push(element);
    }
  });

  const STACK_COLUMN_GAP = 30;

  // Find maximum width for each stack
  for (let i = 0; i < Object.keys(appearanceStacks).length; i++) {
    widthPerStack[i] = Math.max.apply(
      Math,
      appearanceStacks[i].map(
        (element) =>
          Math.max(
            textWidth(element.data.name, 'Verdana, Geneva', 12),
            textWidth(`icon: ${element.data.icon}`, 'Verdana, Geneva', 12),
            textWidth(
              `icon_state: ${element.data.icon_state}`,
              'Verdana, Geneva',
              12,
            ),
            120,
          ) + STACK_COLUMN_GAP,
      ),
    );
  }

  // We can position our elements by going recursively over each stack, and then fixing overlaps
  function positionChildren(appearance: Appearance) {
    const VERTICAL_APPEARANCE_GAP = 15;
    const CENTRAL_APPEARANCE_GAP = 30;
    let curHeight = CENTRAL_APPEARANCE_GAP / 2;
    // First, arrange our children
    if (appearance.overlays) {
      curHeight -= getAppearanceHeight(appearance.overlays[0]) / 2;
      for (let i = 0; i < appearance.overlays.length; i++) {
        appearance.overlays[i].position.x =
          appearance.position.x -
          STACK_COLUMN_GAP -
          widthPerStack[appearance.overlays[i].depth];
        appearance.overlays[i].position.y =
          appearance.position.y -
          curHeight -
          getAppearanceHeight(appearance.overlays[i]);
        curHeight +=
          getAppearanceHeight(appearance.overlays[i]) + VERTICAL_APPEARANCE_GAP;
        positionChildren(appearance.overlays[i]);
      }
    }

    curHeight =
      getAppearanceHeight(appearance) / 2 + CENTRAL_APPEARANCE_GAP / 2;
    if (appearance.underlays) {
      for (let i = appearance.underlays.length - 1; i >= 0; i--) {
        appearance.underlays[i].position.x =
          appearance.position.x -
          STACK_COLUMN_GAP -
          widthPerStack[appearance.underlays[i].depth];
        appearance.underlays[i].position.y = appearance.position.y + curHeight;
        curHeight +=
          getAppearanceHeight(appearance.underlays[i]) +
          VERTICAL_APPEARANCE_GAP;
        positionChildren(appearance.underlays[i]);
      }
    }
  }

  positionChildren(primary);
  return appearances;
}

export function AppearanceDebug() {
  const { data, act } = useBackend<AppearanceDebugData>();
  const { mainAppearance, planeToText, layerToText, mapRef } = data;

  // This is a constant because we do not dynamically refresh, as appearances cannot be modified and rebuild all at once
  // So we do not need to concern ourselves with constant updates, and can just send data in ui_static_data()
  const appsProcessed = parseAppearanceData(mainAppearance);
  const [zoomToX, setZoomToX] = useState<number>();
  const [zoomToY, setZoomToY] = useState<number>();

  return (
    <AppearanceDebugContext.Provider
      value={{
        act,
        mapRef,
        planeToText,
        layerToText,
        appsProcessed,
        zoomToX,
        setZoomToX,
        zoomToY,
        setZoomToY,
      }}
    >
      <Window
        width={1500}
        height={800}
        title={`OverFlayer${mainAppearance.name ? `: ${mainAppearance.name}` : ''}`}
      >
        <Window.Content
          style={{
            backgroundImage: 'none',
          }}
        >
          <ByondUi
            width="256px"
            height="256px"
            params={{
              id: mapRef,
              type: 'map',
            }}
          />
          <InfinitePlane
            width="100%"
            height="100%"
            backgroundImage={resolveAsset('grid_background.png')}
            imageWidth={900}
            initialLeft={500}
            initialTop={-1350}
            zoomToX={-(zoomToX || 0) + 525}
            zoomToY={-(zoomToY || 0) + 300}
          >
            {Object.entries(appsProcessed).map((keyValue) => (
              <AppearanceBox key={keyValue[0]} appearance={keyValue[1]} />
            ))}
          </InfinitePlane>
        </Window.Content>
      </Window>
    </AppearanceDebugContext.Provider>
  );
}
