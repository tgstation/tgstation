import { useCallback, useEffect, useRef, useState } from 'react';
import { Button, Flex, Section, Stack } from 'tgui-core/components';

export type StationMapProps = {
  title?: React.ReactNode;
  allMapData?: Record<string, MapData>;
  targetZ?: number;
  targetX?: number;
  targetY?: number;
  children?: React.ReactNode | ((zoom: number) => React.ReactNode);
  onChangeZ?: (z: number) => void;
};

export type MapData = {
  map_image?: string;
  grid_w?: number;
  grid_h?: number;
  area_grid?: string[][];
};

export const StationMap = (props: StationMapProps) => {
  const {
    title = 'Station Map',
    allMapData,
    targetZ,
    targetX,
    targetY,
    children,
    onChangeZ,
  } = props;

  const [hoverArea, setHoverArea] = useState<string | null>(null);
  const [mousePos, setMousePos] = useState<{ x: number; y: number } | null>(
    null,
  );

  const possibleMaps = Object.keys(allMapData ?? {}).sort(
    (a, b) => Number(b) - Number(a),
  );
  const [zoom, setZoom] = useState(1);
  const [pan, setPan] = useState({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
  const [panStart, setPanStart] = useState({ x: 0, y: 0 });
  const [shownMap, setShownMap] = useState(possibleMaps[0]);
  const viewportRef = useRef<HTMLDivElement>(null);
  const mapRef = useRef<HTMLDivElement>(null);

  const {
    map_image: mapImage,
    grid_w: gridW,
    grid_h: gridH,
    area_grid: areaGrid,
  } = allMapData?.[shownMap] ?? {};

  const focusOnCoordinates = useCallback(
    (xPct: number, yPct: number, zPct: number) => {
      setShownMap(zPct.toString());
      if (!viewportRef.current) return;

      const rect = viewportRef.current.getBoundingClientRect();
      const W = rect.width;
      const H = rect.height;

      const targetZoom = 2.5;
      setZoom(targetZoom);

      const panX = targetZoom * (0.5 - xPct / 100) * W;
      const panY = targetZoom * (yPct / 100 - 0.5) * H;

      setPan({ x: panX, y: panY });
    },
    [],
  );

  useEffect(() => {
    if (
      targetX !== undefined &&
      targetY !== undefined &&
      targetZ !== undefined
    ) {
      focusOnCoordinates(targetX, targetY, targetZ);
    }
  }, [targetX, targetY, targetZ, focusOnCoordinates]);

  useEffect(() => {
    onChangeZ?.(Number(shownMap));
  }, [onChangeZ, shownMap]);

  const handleMouseDown = (e: React.MouseEvent<HTMLDivElement>) => {
    if (e.button !== 0) return;
    setIsDragging(true);
    setDragStart({ x: e.clientX, y: e.clientY });
    setPanStart({ ...pan });
  };

  const handleMouseMove = (e: React.MouseEvent<HTMLDivElement>) => {
    if (!viewportRef.current) return;

    const rect = viewportRef.current.getBoundingClientRect();
    const xInViewport = e.clientX - rect.left;
    const yInViewport = e.clientY - rect.top;

    setMousePos({ x: xInViewport + 12, y: yInViewport + 12 });

    if (isDragging) {
      const dx = e.clientX - dragStart.x;
      const dy = e.clientY - dragStart.y;
      setPan({
        x: panStart.x + dx,
        y: panStart.y + dy,
      });
    }

    if (areaGrid && gridW && gridH && mapRef.current) {
      const mapRect = mapRef.current.getBoundingClientRect();

      const px = e.clientX - mapRect.left;
      const py = e.clientY - mapRect.top;

      const xPct = px / mapRect.width;
      const yPct = 1 - py / mapRect.height;

      if (xPct >= 0 && xPct <= 1 && yPct >= 0 && yPct <= 1) {
        const gridX = Math.min(
          gridW - 1,
          Math.max(0, Math.floor(xPct * gridW)),
        );
        const gridY = Math.min(
          gridH - 1,
          Math.max(0, Math.floor(yPct * gridH)),
        );

        const areaName = areaGrid?.[gridX]?.[gridY];

        if (areaName) {
          setHoverArea(areaName);
          return;
        }
      }
    }

    setHoverArea(null);
  };

  const handleMouseUp = () => {
    setIsDragging(false);
  };

  const handleWheel = (e: React.WheelEvent<HTMLDivElement>) => {
    e.preventDefault();
    if (e.deltaY < 0) {
      setZoom((z) => Math.min(z + 0.3, 4));
    } else {
      setZoom((z) => Math.max(z - 0.3, 1));
    }
  };

  const handleResetZoom = () => {
    setZoom(1);
    setPan({ x: 0, y: 0 });
  };

  return (
    <Section
      fill
      title={title}
      buttons={
        <Stack>
          {Object.keys(allMapData ?? {}).length > 1 && (
            <>
              <Stack.Item>
                <Button
                  icon="plus"
                  onClick={() =>
                    setShownMap(
                      possibleMaps[possibleMaps.indexOf(shownMap) + 1],
                    )
                  }
                  disabled={shownMap === possibleMaps[possibleMaps.length - 1]}
                />
              </Stack.Item>
              <Stack.Item>
                <Button
                  icon="minus"
                  onClick={() =>
                    setShownMap(
                      possibleMaps[possibleMaps.indexOf(shownMap) - 1],
                    )
                  }
                  disabled={shownMap === possibleMaps[0]}
                />
              </Stack.Item>
            </>
          )}
          <Stack.Item>
            <Button
              icon="search-minus"
              onClick={() => setZoom((z) => Math.max(z - 0.4, 1))}
            />
          </Stack.Item>
          <Stack.Item>
            <Button icon="undo" onClick={handleResetZoom}>
              Reset
            </Button>
          </Stack.Item>
        </Stack>
      }
    >
      <Flex align="center" justify="center" height="100%">
        <div
          ref={viewportRef}
          onWheel={handleWheel}
          onMouseDown={handleMouseDown}
          onMouseMove={handleMouseMove}
          onMouseUp={handleMouseUp}
          onMouseLeave={() => {
            setIsDragging(false);
            setHoverArea(null);
            setMousePos(null);
          }}
          style={{
            position: 'relative',
            width: '100%',
            maxWidth: '100%',
            maxHeight: '100%',
            aspectRatio: '1 / 1',
            backgroundColor: '#050505',
            overflow: 'hidden',
            borderRadius: '4px',
            border: '1px solid #1f1f1f',
            cursor: isDragging ? 'grabbing' : 'grab',
          }}
        >
          <div
            ref={mapRef}
            style={{
              position: 'absolute',
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              margin: 'auto',
              width: '100%',
              maxHeight: '100%',
              aspectRatio: gridW && gridH ? `${gridW} / ${gridH}` : '1 / 1',
              backgroundImage: mapImage ? `url(${mapImage})` : 'none',
              backgroundSize: '100% 100%',
              border: '10px solid #050505',
              backgroundRepeat: 'no-repeat',
              imageRendering: 'pixelated',
              transform: `translate(${pan.x}px, ${pan.y}px) scale(${zoom})`,
              transformOrigin: 'center center',
              transition: isDragging ? 'none' : 'transform 0.15s ease-out',
            }}
          >
            {typeof children === 'function' ? children(zoom) : children}
          </div>

          {!!hoverArea && !!mousePos && !isDragging && (
            <div
              style={{
                position: 'absolute',
                left: `${mousePos.x}px`,
                top: `${mousePos.y}px`,
                backgroundColor: 'rgba(0, 0, 0, 0.9)',
                color: '#ffffff',
                padding: '3px 8px',
                borderRadius: '3px',
                fontSize: '12px',
                fontWeight: 'bold',
                border: '1px solid rgba(255, 255, 255, 0.4)',
                pointerEvents: 'none',
                zIndex: 30,
                boxShadow: '0 2px 8px rgba(0,0,0,0.8)',
                whiteSpace: 'nowrap',
              }}
            >
              {hoverArea}
            </div>
          )}
        </div>
      </Flex>
    </Section>
  );
};
