import { useState } from 'react';
import { resolveAsset } from 'tgui/assets';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  ByondUi,
  Dropdown,
  InfinitePlane,
  Stack,
} from 'tgui-core/components';
import { Window } from '../../layouts';
import {
  type Connection,
  Connections,
  type Coordinates,
} from '../common/Connections';
import { AppearanceBox } from './AppearanceBox';
import { AppearanceInfo } from './AppearanceInfo';
import type {
  Appearance,
  AppearanceData,
  AppearanceDebugData,
  AppearanceMap,
} from './types';
import {
  APPEARANCE_FLAGS,
  AppearanceParentType,
  AppearanceType,
  HiddenState,
  VIS_FLAGS,
} from './types';
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
  parentType: AppearanceParentType = AppearanceParentType.None,
  depth: number = 0,
  appearances: AppearanceMap = {},
  planeFilter: number | null,
  hideEmissives: boolean,
) {
  const appearance: Appearance = {
    data: appearance_data,
    underlays: null,
    overlays: null,
    parent: parent,
    hidden: HiddenState.Visible,
    boundingBox: [
      { x: 0, y: 0 },
      { x: 0, y: 0 },
    ],
    parentType: parentType,
    renderTargetTo: null,
    relativePosition: { x: 0, y: 0 },
    depth: depth,
  };
  if (
    hideEmissives &&
    (isEmissive(appearance) || isEmissiveBlocker(appearance))
  )
    appearance.hidden = HiddenState.Hidden;
  else if (planeFilter !== null && appearance.data.plane_true !== planeFilter)
    appearance.hidden = HiddenState.Hidden;
  appearances[appearance_data.id] = appearance;
  let underlays = appearance_data.underlays;
  if (appearance_data.vis_contents)
    underlays = underlays.concat(
      appearance_data.vis_contents.filter(
        (x) => x.vis_flags && x.vis_flags & VIS_FLAGS.VIS_UNDERLAY,
      ),
    );
  if (underlays.length > 0) {
    appearance.underlays = underlays
      .map((data) =>
        mapAppearance(
          data,
          appearance,
          AppearanceParentType.Underlay,
          depth + 1,
          appearances,
          planeFilter,
          hideEmissives,
        ),
      )
      .sort((a, b) =>
        a.data.plane === b.data.plane
          ? a.data.layer - b.data.layer
          : a.data.plane - b.data.plane,
      );
    if (
      appearance.hidden === HiddenState.Hidden &&
      appearance.underlays.filter((x) => x.hidden !== HiddenState.Hidden)
        .length > 0
    )
      appearance.hidden = HiddenState.VisibleChild;
  }
  let overlays = appearance_data.overlays;
  if (appearance_data.vis_contents)
    overlays = overlays.concat(
      appearance_data.vis_contents.filter(
        (x) => !x.vis_flags || !(x.vis_flags & VIS_FLAGS.VIS_UNDERLAY),
      ),
    );
  if (overlays.length > 0) {
    appearance.overlays = overlays
      .map((data) =>
        mapAppearance(
          data,
          appearance,
          AppearanceParentType.Overlay,
          depth + 1,
          appearances,
          planeFilter,
          hideEmissives,
        ),
      )
      // vis_contents get priority by layer over overlays, but not by plane
      .sort((a, b) =>
        a.data.plane === b.data.plane
          ? a.data.type === AppearanceType.Atom &&
            b.data.type !== AppearanceType.Atom
            ? 1
            : a.data.type !== AppearanceType.Atom &&
                b.data.type === AppearanceType.Atom
              ? -1
              : a.data.layer - b.data.layer
          : a.data.plane - b.data.plane,
      );
    if (
      appearance.hidden === HiddenState.Hidden &&
      appearance.overlays.filter((x) => x.hidden !== HiddenState.Hidden)
        .length > 0
    )
      appearance.hidden = HiddenState.VisibleChild;
  }
  return appearance;
}

function getAppearanceHeight(appearance: Appearance) {
  const TITLEBAR = 27;
  const COLUMN_BREAK = 20;
  let rows = 0;
  if (appearance.data.icon) rows++;
  if (appearance.data.icon_state) rows++;
  if (appearance.data.layer) rows++;
  if (appearance.data.plane) rows++;
  let height = COLUMN_BREAK + TITLEBAR + rows * 15 + (rows - 1) * 6 - 8;
  if (appearance.data.embed_icon) height += 64 + 6;
  return height;
}

export function isEmissive(appearance: Appearance) {
  const EMISSIVE_PLANE = 13;
  // Emissives are always constant color matrixes
  if (
    appearance.data.plane_true !== EMISSIVE_PLANE ||
    !Array.isArray(appearance.data.color)
  )
    return false;
  const colorMatrix = appearance.data.color as number[];
  for (let i = 0; i < colorMatrix.length; i++) {
    if (i === 15 && colorMatrix[i] !== 1) return false;
    else if (colorMatrix[i] !== 0 && (i < 15 || i > 18)) return false;
  }
  return true;
}

export function isEmissiveBlocker(appearance: Appearance) {
  const EMISSIVE_PLANE = 13;
  // Emissive blockers can be a constant matrix or pure black
  if (appearance.data.plane_true !== EMISSIVE_PLANE || !appearance.data.color)
    return false;
  if (appearance.data.color === '#000000') return true;
  if (!Array.isArray(appearance.data.color)) return false;
  const colorMatrix = appearance.data.color as number[];
  for (let i = 0; i < colorMatrix.length; i++) {
    if (colorMatrix[i] !== 0 && i !== 15) return false;
  }
  return true;
}

function getAppearanceWidth(
  appearance: Appearance,
  layerToText: Record<string, number>,
  planeToText: Record<string, number>,
) {
  return Math.max(
    textWidth(
      (appearance.data.name || appearance.data.icon_state) +
        (isEmissive(appearance)
          ? ' (Emissive)'
          : isEmissiveBlocker(appearance)
            ? ' (Emissive Blocker)'
            : ''),
      'Verdana, Geneva',
      12,
    ) + 18,
    textWidth(`icon: ${appearance.data.icon}`, 'Verdana, Geneva', 12) + 12,
    textWidth(
      `icon_state: ${appearance.data.icon_state}`,
      'Verdana, Geneva',
      12,
    ) + 12,
    layerToText &&
      textWidth(
        `layer: ${getReadableLayer(appearance, layerToText)}`,
        'Verdana, Geneva',
        12,
      ) + 12,
    planeToText &&
      textWidth(
        `plane: ${getReadablePlane(appearance, planeToText)}`,
        'Verdana, Geneva',
        12,
      ) + 12,
    150,
  );
}

export function getReadableLayer(
  appearance: Appearance,
  layerToText: Record<string, number>,
) {
  return (
    (appearance.data.layer_text_override ||
      Object.keys(layerToText).find(
        (x) => layerToText[x] === appearance.data.layer,
      ) ||
      '') + (appearance.data.layer !== -1 ? ` (${appearance.data.layer})` : '')
  );
}

export function getReadablePlane(
  appearance: Appearance,
  planeToText: Record<string, number>,
) {
  return (
    (Object.keys(planeToText).find(
      (x) => planeToText[x] === appearance.data.plane_true,
    ) || appearance.data.plane_true.toString()) +
    (appearance.data.plane !== -32767 ? ` (${appearance.data.plane})` : '')
  );
}

function parseAppearanceData(
  mainAppearance: AppearanceData,
  layerToText: Record<string, number>,
  planeToText: Record<string, number>,
  planeFilter: number | null,
  hideEmissives: boolean,
) {
  const appearances: AppearanceMap = {};
  // Recursively map all appearances
  const primary: Appearance = mapAppearance(
    mainAppearance,
    null,
    AppearanceParentType.None,
    0,
    appearances,
    planeFilter,
    hideEmissives,
  );

  const sourceMap: Record<string, Appearance> = {};
  Object.values(appearances).forEach((element) => {
    if (element.data.render_target)
      sourceMap[element.data.render_target] = element;
  });

  Object.values(appearances).forEach((element) => {
    if (element.data.render_source && element.data.render_source in sourceMap) {
      if (sourceMap[element.data.render_source].renderTargetTo === null)
        sourceMap[element.data.render_source].renderTargetTo = [];
      sourceMap[element.data.render_source].renderTargetTo?.push(element);
    }
  });

  const STACK_COLUMN_GAP = 60;
  const KEEP_APART_TOGETHER_GAP = 18;
  const KEEP_APART_TOGETHER_GAP_TOP = 30;

  // Returns a *relative* bounding box, includes KEEP_TOGETHER/APART borders!
  function getBoundingBox(appearance: Appearance): [Coordinates, Coordinates] {
    let minX = 0;
    let minY = 0;
    let maxX = getAppearanceWidth(appearance, layerToText, planeToText);
    let maxY = getAppearanceHeight(appearance);

    if (appearance.underlays) {
      for (let i = 0; i < appearance.underlays.length; i++) {
        const underlay = appearance.underlays[i];
        if (underlay.hidden === HiddenState.Hidden) continue;
        const underlayBox = getBoundingBox(underlay);
        minX = Math.min(minX, underlayBox[0].x + underlay.relativePosition.x);
        minY = Math.min(minY, underlayBox[0].y + underlay.relativePosition.y);
        // Shouldn't happen with maxX but just in case
        maxX = Math.max(maxX, underlayBox[1].x + underlay.relativePosition.x);
        maxY = Math.max(maxY, underlayBox[1].y + underlay.relativePosition.y);
      }
    }

    if (appearance.overlays) {
      for (let i = 0; i < appearance.overlays.length; i++) {
        const overlay = appearance.overlays[i];
        if (overlay.hidden === HiddenState.Hidden) continue;
        const overlayBox = getBoundingBox(overlay);
        minX = Math.min(minX, overlayBox[0].x + overlay.relativePosition.x);
        minY = Math.min(minY, overlayBox[0].y + overlay.relativePosition.y);
        // Shouldn't happen with maxX but just in case
        maxX = Math.max(maxX, overlayBox[1].x + overlay.relativePosition.x);
        maxY = Math.max(maxY, overlayBox[1].y + overlay.relativePosition.y);
      }
    }

    if (
      appearance.data.flags &
      (APPEARANCE_FLAGS.KEEP_TOGETHER | APPEARANCE_FLAGS.KEEP_APART)
    ) {
      minX -= KEEP_APART_TOGETHER_GAP;
      minY -= KEEP_APART_TOGETHER_GAP_TOP;
      maxX += KEEP_APART_TOGETHER_GAP;
      maxY += KEEP_APART_TOGETHER_GAP;
    }

    return [
      { x: minX, y: minY },
      { x: maxX, y: maxY },
    ];
  }

  // By recursing through our children we can have them position their
  // children's relative positions, and then position them based on said
  // children's positions and bounding boxes when going back
  function positionChildren(appearance: Appearance) {
    const VERTICAL_APPEARANCE_GAP = 15;
    const CENTRAL_APPEARANCE_GAP = 30;

    if (appearance.overlays) {
      let minHeight =
        -getAppearanceHeight(appearance) / 2 + CENTRAL_APPEARANCE_GAP / 2;
      let totalOverlayHeight = 0;
      for (let i = 0; i < appearance.overlays.length; i++) {
        const overlay = appearance.overlays[i];
        if (overlay.hidden === HiddenState.Hidden) continue;
        positionChildren(overlay);
        const overlayBounds = getBoundingBox(overlay);
        overlay.boundingBox = overlayBounds;
        overlay.relativePosition.x =
          -STACK_COLUMN_GAP -
          getAppearanceWidth(overlay, layerToText, planeToText);
        overlay.relativePosition.y = -minHeight - overlayBounds[1].y;
        const totalHeight =
          overlayBounds[1].y - overlayBounds[0].y + VERTICAL_APPEARANCE_GAP;
        minHeight += totalHeight;
        totalOverlayHeight += totalHeight;
      }
      // If we don't have any underlays, shift all overlays down
      if (
        !appearance.underlays?.filter((x) => x.hidden !== HiddenState.Hidden)
          .length
      ) {
        const staticShift =
          CENTRAL_APPEARANCE_GAP / 2 +
          (totalOverlayHeight - VERTICAL_APPEARANCE_GAP) / 2;
        for (let i = 0; i < appearance.overlays.length; i++) {
          appearance.overlays[i].relativePosition.y += staticShift;
        }
      }
    }

    if (appearance.underlays) {
      let minHeight =
        getAppearanceHeight(appearance) / 2 - CENTRAL_APPEARANCE_GAP / 2;
      let totalUnderlayHeight = 0;
      for (let i = 0; i < appearance.underlays.length; i++) {
        const underlay = appearance.underlays[i];
        if (underlay.hidden === HiddenState.Hidden) continue;
        positionChildren(underlay);
        const underlayBounds = getBoundingBox(underlay);
        underlay.boundingBox = underlayBounds;
        underlay.relativePosition.x =
          -STACK_COLUMN_GAP -
          getAppearanceWidth(underlay, layerToText, planeToText);
        underlay.relativePosition.y = minHeight + getAppearanceHeight(underlay);
        const totalHeight =
          underlayBounds[1].y - underlayBounds[0].y + VERTICAL_APPEARANCE_GAP;
        minHeight += totalHeight;
        totalUnderlayHeight += totalHeight;
      }
      // If we don't have any overlays, shift all underlays up
      if (
        !appearance.overlays?.filter((x) => x.hidden !== HiddenState.Hidden)
          .length
      ) {
        const staticShift =
          CENTRAL_APPEARANCE_GAP / 2 +
          (totalUnderlayHeight - VERTICAL_APPEARANCE_GAP) / 2;
        for (let i = 0; i < appearance.underlays.length; i++) {
          appearance.underlays[i].relativePosition.y -= staticShift;
        }
      }
    }
  }

  positionChildren(primary);
  primary.boundingBox = getBoundingBox(primary);
  return appearances;
}

export function AppearanceDebug() {
  const { data, act } = useBackend<AppearanceDebugData>();
  const {
    mainAppearance,
    planeToText,
    layerToText,
    mapRefHover,
    mapRefSelected,
  } = data;
  const [planeFilter, setPlaneFilter] = useState<string | null>(null);
  const [hideEmissives, setHideEmissives] = useState(false);

  // This is a constant because we do not dynamically refresh, as appearances cannot be modified and rebuild all at once
  // So we do not need to concern ourselves with constant updates, and can just send data in ui_static_data()
  const appsProcessed = parseAppearanceData(
    mainAppearance,
    layerToText,
    planeToText,
    planeFilter ? planeToText[planeFilter] : null,
    hideEmissives,
  );
  const [zoomToX, setZoomToX] = useState<number>();
  const [zoomToY, setZoomToY] = useState<number>();
  const [selection, setSelection] = useState<number | null>(null);

  function mapPosition(
    appearance: Appearance,
    positions: Record<number, Coordinates>,
  ) {
    if (appearance.data.id in positions) return positions[appearance.data.id];
    const position: Coordinates = {
      x: appearance.relativePosition.x,
      y: appearance.relativePosition.y,
    };
    if (appearance.parent) {
      if (!(appearance.parent.data.id in positions))
        mapPosition(appearance.parent, positions);
      position.x += positions[appearance.parent.data.id].x;
      position.y += positions[appearance.parent.data.id].y;
    }
    positions[appearance.data.id] = position;
    return position;
  }

  const NODE_PADDING = 20;
  const OVERLAY_NODE_INPUT_PADDING = 60;
  const UNDERLAY_NODE_INPUT_PADDING = 40;

  const connections: Connection[] = [];
  const appearancePositions: Record<number, Coordinates> = {};
  for (let i = 0; i < Object.keys(appsProcessed).length; i++) {
    const appearance = appsProcessed[
      Object.keys(appsProcessed)[i]
    ] as Appearance;
    if (!appearance.parent || appearance.hidden === HiddenState.Hidden)
      continue;
    const position = mapPosition(appearance, appearancePositions);
    const parentPosition = mapPosition(appearance.parent, appearancePositions);
    connections.push({
      from: {
        x:
          position.x +
          getAppearanceWidth(appearance, layerToText, planeToText) -
          NODE_PADDING,
        y: position.y + getAppearanceHeight(appearance) / 2,
      },
      to: {
        x: parentPosition.x + NODE_PADDING,
        y:
          appearance.parentType === AppearanceParentType.Overlay
            ? parentPosition.y + OVERLAY_NODE_INPUT_PADDING
            : parentPosition.y +
              getAppearanceHeight(appearance.parent) -
              UNDERLAY_NODE_INPUT_PADDING,
      },
      index: i,
      color: `hsl(${60 + 5 * (i % 30)}, 50%, ${50 + (i % 30)}%)`,
    });
  }

  return (
    <AppearanceDebugContext.Provider
      value={{
        act,
        mapRefHover,
        mapRefSelected,
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
        width={1600}
        height={840}
        title={`OverFlayer${mainAppearance.name || mainAppearance.icon_state ? `: ${mainAppearance.name || mainAppearance.icon_state}` : ''}`}
        buttons={
          <Stack fill>
            <Stack.Item
              width={`${
                Math.max(
                  90,
                  textWidth(
                    Object.keys(planeToText)
                      .sort((a, b) => a.length - b.length)
                      .pop() as string,
                    'Verdana, Geneva',
                    12,
                  ),
                ) + 40
              }px`}
            >
              <Dropdown
                options={Object.keys(planeToText).sort()}
                placeholder="Filter by Plane"
                selected={planeFilter || ''}
                searchInput
                onSelected={(value) => {
                  setSelection(null);
                  if (!(value in planeToText)) setPlaneFilter(null);
                  setPlaneFilter(value);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                color={hideEmissives ? 'green' : 'transparent'}
                tooltip="Hide Emissives"
                icon="ban"
                selected={hideEmissives}
                onClick={() => {
                  setSelection(null);
                  setHideEmissives(!hideEmissives);
                }}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                color="transparent"
                tooltip="Refresh Appearance"
                icon="arrows-rotate"
                onClick={() => act('refreshAppearance')}
              />
            </Stack.Item>
          </Stack>
        }
      >
        <Window.Content
          style={{
            backgroundImage: 'none',
          }}
        >
          <Box
            className="Tooltip"
            position="absolute"
            left="12px"
            top="42px"
            width="172px"
            height="172px"
            pl="6px"
            pr="6px"
            style={{ zIndex: 3 }}
          >
            <ByondUi
              width="160px"
              height="160px"
              params={{
                id: mapRefHover,
                type: 'map',
              }}
            />
          </Box>
          <InfinitePlane
            width="100%"
            height="100%"
            backgroundImage={resolveAsset('grid_background.png')}
            imageWidth={900}
            initialLeft={500}
            initialTop={-1350}
            zoomPadding={selection !== null ? 400 : 0}
            zoomToX={-(zoomToX || 0) + 525}
            zoomToY={-(zoomToY || 0) + 300}
          >
            {Object.entries(appsProcessed)
              .filter((keyValue) => keyValue[1].hidden !== HiddenState.Hidden)
              .map((keyValue) => (
                <AppearanceBox
                  key={keyValue[0]}
                  appearance={keyValue[1]}
                  position={mapPosition(keyValue[1], appearancePositions)}
                  onClick={(event) => {
                    setSelection(keyValue[1].data.id);
                    act('setMapViewSelected', { id: keyValue[1].data.id });
                  }}
                />
              ))}
            <Connections connections={connections} />
          </InfinitePlane>
          {!!(selection !== null) && (
            <AppearanceInfo
              appearance={
                Object.values(appsProcessed).find(
                  (x) => x.data.id === selection,
                ) as Appearance
              }
              onClose={() => setSelection(null)}
            />
          )}
        </Window.Content>
      </Window>
    </AppearanceDebugContext.Provider>
  );
}
