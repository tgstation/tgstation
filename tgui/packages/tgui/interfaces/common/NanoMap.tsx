import '../../styles/interfaces/NanoMap.scss';

import { useLocalStorage } from '@uidotdev/usehooks';
import {
  createContext,
  type Dispatch,
  type ReactNode,
  type SetStateAction,
  useContext,
  useEffect,
} from 'react';
import {
  KeepScale,
  MiniMap,
  TransformComponent,
  TransformWrapper,
  useControls,
} from 'react-zoom-pan-pinch';
import { Button, Image, Stack } from 'tgui-core/components';
import { clamp01 } from 'tgui-core/math';
import { type BooleanLike, classes } from 'tgui-core/react';
import { throttle } from 'tgui-core/timer';
import { resolveAsset } from '../../assets';
import { Direction } from '../../constants';

export type MapData = {
  name: string;
  minFloor: number;
  mainFloor: number;
  maxFloor: number;
  lavalandLevel: number;
  stairs: Stair[];
};

type Stair = {
  posX: number;
  posY: number;
  posZ: number;
};

type Props = {
  /** Content on map. Like buttons. Use only NanoMap.xxx components */
  children?: ReactNode;
  /** Additional control buttons container */
  buttons?: ReactNode;
  /** Allows you to disable minimap */
  minimapDisabled?: BooleanLike;
  /**
   * Changes minimap position.
   ** Allowed values: 'top-left', 'top-right', 'bottom-left', 'bottom-right'
   ** Default: 'top-left'
   */
  minimapPosition?: MinimapPosition;
  /** All needed map data from backend */
  mapData: MapData;
  /** Called when level changes. Returns current level */
  onLevelChange: (level: number) => void;
};

type MinimapPosition =
  | 'top-left'
  | 'top-right'
  | 'bottom-left'
  | 'bottom-right';

const defaultScale = 0.125;
const maxScale = defaultScale * 8;

/// Each tile is 16px size, we have 256 tiles
const defaultMapSize = 4080;
const tileSize = defaultMapSize / 255;

/** Converts object position to pixel position.*/
function posToPx(pos: number) {
  return `${pos * tileSize - tileSize}px`;
}

/** Converts Byond direction to direction */
function dirToDeg(dir: Direction) {
  switch (dir) {
    case Direction.NORTH:
      return 180;
    case Direction.EAST:
      return 270;
    case Direction.SOUTH:
      return 0;
    case Direction.WEST:
      return 90;
  }
}

type MapState = {
  scale: number;
  positionX: number;
  positionY: number;
  currentLevel: number;
  minimap: boolean;
};

type NanoMapContextType = {
  mapData: MapData;
  mapState: MapState;
  setMapState: Dispatch<SetStateAction<MapState>>;
};

export const NanoMapContext = createContext<NanoMapContextType | null>(null);

export function NanoMap(props: Props) {
  const {
    children,
    buttons,
    mapData,
    minimapDisabled,
    minimapPosition,
    onLevelChange,
  } = props;

  const [mapState, setMapState] = useLocalStorage<MapState>('nanomap-state', {
    scale: defaultScale,
    positionX: 0,
    positionY: 0,
    currentLevel: mapData.mainFloor,
    minimap: true,
  });

  function getMapImage(level: number) {
    const { name, lavalandLevel, minFloor } = mapData;
    const image =
      level === lavalandLevel && lavalandLevel !== minFloor
        ? 'Lavaland_nanomap_z1.png'
        : `${name}_nanomap_z${level - 1}.png`;

    return (
      <Image
        width={`${defaultMapSize}px`}
        height={`${defaultMapSize}px`}
        src={resolveAsset(image)}
      />
    );
  }

  function handleTransformed({ state }) {
    setMapState((prev) => ({
      ...prev,
      positionX: state.positionX,
      positionY: state.positionY,
      scale: state.scale,
    }));
  }

  const { scale, positionX, positionY, currentLevel, minimap } = mapState;

  // Send component data to UI, if he has useState for them.
  useEffect(() => {
    onLevelChange?.(currentLevel);
  }, [currentLevel]);

  const mapImage = getMapImage(currentLevel);

  return (
    <NanoMapContext.Provider
      value={{ mapData: mapData, mapState: mapState, setMapState: setMapState }}
    >
      <TransformWrapper
        centerOnInit={positionX === 0 && positionY === 0}
        minScale={defaultScale}
        maxScale={maxScale}
        initialScale={scale}
        initialPositionX={positionX}
        initialPositionY={positionY}
        wheel={{ step: defaultScale }}
        doubleClick={{ disabled: true }}
        panning={{ velocityDisabled: true }}
        onTransformed={throttle((state) => {
          handleTransformed(state);
        }, 1000)} // Saving 1 time at a second, let's not fuck localState
      >
        <Stack
          fill
          vertical
          className={classes([
            'NanoMap',
            minimapPosition && `NanoMap--${minimapPosition}`,
          ])}
        >
          <Stack.Item grow minHeight={0} minWidth={0}>
            <div
              className={classes([
                'NanoMap__Minimap--container',
                (minimapDisabled || !minimap) && 'NanoMap__Minimap--disabled',
              ])}
            >
              <NanoMapButtons minimapDisabled={minimapDisabled}>
                {buttons}
              </NanoMapButtons>
              {!minimapDisabled && minimap && (
                <MiniMap className="NanoMap__Minimap" width={150}>
                  {mapImage}
                </MiniMap>
              )}
              <NanoMapControls />
            </div>
            <TransformComponent
              wrapperStyle={{ width: '100%', height: '100%' }}
            >
              {mapImage}
              <div>{children}</div>
            </TransformComponent>
          </Stack.Item>
        </Stack>
      </TransformWrapper>
    </NanoMapContext.Provider>
  );
}

function NanoMapControls() {
  const { zoomIn, zoomOut, centerView } = useControls();
  const context = useContext(NanoMapContext);
  if (!context) {
    return null;
  }

  return (
    <div className="NanoMap__Controls">
      <Button icon="minus" onClick={() => zoomOut(maxScale)} />
      <Button fluid width="100%" onClick={() => centerView()}>
        <div
          className="NanoMap__Controls--zoom"
          style={{ width: `${clamp01(context.mapState.scale) * 100}%` }}
        />
        Центр
      </Button>
      <Button icon="plus" onClick={() => zoomIn(maxScale)} />
    </div>
  );
}

function NanoMapButtons(props) {
  const { children, minimapDisabled } = props;
  const context = useContext(NanoMapContext);
  if (!context) {
    return null;
  }

  const { mapState, setMapState } = context;
  const { minimap } = mapState;

  return (
    <Stack fill vertical className="NanoMap__Buttons">
      <Stack.Item grow>
        <NanoMapLevelSelector />
      </Stack.Item>
      <Stack.Item>{children}</Stack.Item>
      {!minimapDisabled && (
        <Stack.Item>
          <Button
            selected={!minimap}
            icon={minimap ? 'eye' : 'eye-slash'}
            onClick={() =>
              setMapState((prev) => ({ ...prev, minimap: !minimap }))
            }
          />
        </Stack.Item>
      )}
    </Stack>
  );
}

function NanoMapLevelSelector() {
  const context = useContext(NanoMapContext);
  if (!context) {
    return null;
  }

  const { mapData, mapState, setMapState } = context;
  const { minFloor, maxFloor, mainFloor, lavalandLevel } = mapData;
  const { currentLevel } = mapState;

  function setLevel(level: number) {
    setMapState((prev) => ({ ...prev, currentLevel: level }));
  }

  return (
    <Stack vertical>
      {minFloor !== maxFloor && (
        <>
          <Stack.Item>
            <Button
              icon="chevron-up"
              disabled={currentLevel >= maxFloor}
              onClick={() => setLevel(currentLevel + 1)}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="chevron-down"
              disabled={currentLevel > maxFloor || currentLevel <= minFloor}
              onClick={() => setLevel(currentLevel - 1)}
            />
          </Stack.Item>
        </>
      )}
      {lavalandLevel > maxFloor && (
        <Stack.Item>
          <Button
            icon="volcano"
            selected={currentLevel === lavalandLevel}
            tooltip="Лаваленд"
            onClick={() =>
              setLevel(
                currentLevel === lavalandLevel ? mainFloor : lavalandLevel,
              )
            }
          />
        </Stack.Item>
      )}
    </Stack>
  );
}

/** TODO: Add types when <Button> types will exported */
function MapButton(props) {
  const {
    posX,
    posY,
    posZ,
    direction,
    tracking,
    highlighted,
    hidden,
    ...rest
  } = props;

  const context = useContext(NanoMapContext);
  if (!context) {
    return null;
  }

  const buttonId = `${posX}_${posY}`;
  const { zoomToElement } = useControls();
  const { mapData, mapState, setMapState } = context;

  useEffect(() => {
    if (tracking && props.selected && !hidden) {
      zoomToElement('selected', mapState.scale, 1000, 'linear');
    }
  }, [posX, posY]);

  useEffect(() => {
    if (
      tracking &&
      props.selected &&
      posZ >= mapData.minFloor &&
      posZ <= mapData.maxFloor
    ) {
      setMapState((prev) => ({
        ...prev,
        currentLevel: posZ,
      }));
    }
  }, [posZ]);

  return (
    <div
      id={props.selected ? 'selected' : buttonId}
      className={classes([
        'NanoMap__Object--wrapper',
        hidden && 'NanoMap__Object--hidden',
        props.selected && 'NanoMap__Object--selected',
        tracking && 'tracked',
        highlighted && 'highlighted',
      ])}
      style={{
        transform: `translate(calc(${posToPx(posX)} + 17.5%), calc(${posToPx(256 - posY)} + 5%)) scale(var(--map-button-scale))`,
      }}
    >
      <KeepScale>
        <div className="NanoMap__Object--inner">
          {highlighted && <div className="NanoMap__Object--highlighted" />}
          {direction && (
            <div
              className="NanoMap__Object--direction"
              style={{ transform: `rotate(${dirToDeg(direction)}deg)` }}
            >
              <svg viewBox="0 0 66 66">
                <polygon points="100,75 200,250 0,250" />
              </svg>
            </div>
          )}
          <Button
            {...rest}
            className={classes([
              'NanoMap__Object',
              props.circular && 'NanoMap__Object--circular',
              props.selected && 'NanoMap__Object--selected',
            ])}
            tooltipPosition={props.tooltipPosition || 'top-end'}
            onClick={(event) => {
              if (props.onClick) {
                props.onClick(event);
              }
            }}
          />
        </div>
      </KeepScale>
    </div>
  );
}

NanoMap.Button = MapButton;
