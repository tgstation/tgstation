import { useCallback, useEffect, useRef, useState } from 'react';
import { Button, Flex, Section } from 'tgui-core/components';

export type StationMapProps = {
  title?: React.ReactNode;
  mapImage?: string;
  gridW?: number;
  gridH?: number;
  areaGrid?: string[][];
  targetX?: number;
  targetY?: number;
  children?: React.ReactNode | ((zoom: number) => React.ReactNode);
};

export const StationMap = (props: StationMapProps) => {
  const {
    title = 'Station Map',
    mapImage,
    gridW,
    gridH,
    areaGrid,
    targetX,
    targetY,
    children,
  } = props;

  const [hoverArea, setHoverArea] = useState<string | null>(null);
  const [mousePos, setMousePos] = useState<{ x: number; y: number } | null>(
    null,
  );

  const [zoom, setZoom] = useState(1);
  const [pan, setPan] = useState({ x: 0, y: 0 });
  const [isDragging, setIsDragging] = useState(false);
  const [dragStart, setDragStart] = useState({ x: 0, y: 0 });
  const [panStart, setPanStart] = useState({ x: 0, y: 0 });

  const viewportRef = useRef<HTMLDivElement>(null);

  const focusOnCoordinates = useCallback((xPct: number, yPct: number) => {
    if (!viewportRef.current) return;

    const rect = viewportRef.current.getBoundingClientRect();
    const W = rect.width;
    const H = rect.height;

    const targetZoom = 2.5;
    setZoom(targetZoom);

    const panX = targetZoom * (0.5 - xPct / 100) * W;
    const panY = targetZoom * (yPct / 100 - 0.5) * H;

    setPan({ x: panX, y: panY });
  }, []);

  useEffect(() => {
    if (targetX !== undefined && targetY !== undefined) {
      focusOnCoordinates(targetX, targetY);
    }
  }, [targetX, targetY, focusOnCoordinates]);

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

    if (areaGrid && gridW && gridH) {
      const W = rect.width;
      const H = rect.height;

      const px = (xInViewport - W / 2 - pan.x) / zoom + W / 2;
      const py = (yInViewport - H / 2 - pan.y) / zoom + H / 2;

      const xPct = px / W;
      const yPct = 1 - py / H;

      const gridX = Math.min(gridW - 1, Math.max(0, Math.floor(xPct * gridW)));
      const gridY = Math.min(gridH - 1, Math.max(0, Math.floor(yPct * gridH)));

      const areaName = areaGrid?.[gridX]?.[gridY];

      if (areaName) {
        setHoverArea(areaName);
        return;
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
        <>
          <Button
            icon="search-plus"
            onClick={() => setZoom((z) => Math.min(z + 0.4, 4))}
          />
          <Button
            icon="search-minus"
            onClick={() => setZoom((z) => Math.max(z - 0.4, 1))}
          />
          <Button icon="undo" onClick={handleResetZoom}>
            Reset
          </Button>
        </>
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
                fontSize: '11px',
                fontFamily: 'monospace',
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
