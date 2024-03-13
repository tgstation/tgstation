import { useState } from 'react';

import { resolveAsset } from '../assets';
import { useBackend } from '../backend';
import { Button, Image, NoticeBox } from '../components';
import { Window } from '../layouts';

const TILE_SIZE = 32;
const MINIMAP_WIDTH_HEIGHT = 16;

type MinimapData = {
  z: number;
  name: string;
  sectionWidth: number;
  sectionHeight: number;
  sectionColumns: number;
  sectionRows: number;
  totalWidth: number;
  totalHeight: number;
  tileOffsetX: number;
  tileOffsetY: number;
};

type MinimapBackend = {
  xCoord: number;
  yCoord: number;
  zCoord: number;
  zData: [MinimapData];
};

const SectionImageSource = (
  sectionX: number,
  sectionY: number,
  zLevel: number,
) => resolveAsset(`minimap_${sectionX}_${sectionY}_${zLevel}.png`);

export const Minimap = () => {
  const { data } = useBackend<MinimapBackend>();
  const { xCoord, yCoord, zCoord, zData } = data;

  const activeData = zData[zCoord - 1];
  if (!activeData) {
    return (
      <Window>
        <Window.Content>
          <NoticeBox>Sensor Array Failure</NoticeBox>
        </Window.Content>
      </Window>
    );
  }

  const [sizeMod, setSizeMod] = useState(1);

  const effectiveY = activeData.totalHeight - yCoord + 2;
  const gridSize = MINIMAP_WIDTH_HEIGHT * sizeMod;
  const windowSize = TILE_SIZE * gridSize;

  return (
    <Window
      title={activeData.name}
      width={windowSize}
      height={windowSize}
      buttons={
        <>
          <Button
            icon="plus"
            onClick={() => setSizeMod(sizeMod + 0.25)}
            disabled={sizeMod >= 2}
          />
          <Button
            icon="minus"
            onClick={() => setSizeMod(sizeMod - 0.25)}
            disabled={sizeMod <= 1}
          />
          <Button
            icon="refresh"
            onClick={() => setSizeMod(1)}
            disabled={sizeMod === 1}
          />
        </>
      }
    >
      <Window.Content fitted>
        {Array.from({ length: activeData.sectionRows }).map((_, y) => (
          <div
            key={y}
            style={{
              display: 'flex',
              justifyContent: 'center',
            }}
          >
            {Array.from({ length: activeData.sectionColumns }, (_, x) => (
              <Image
                src={SectionImageSource(
                  x + 1,
                  activeData.sectionRows - y,
                  zCoord,
                )}
                position="relative"
                left={`-${TILE_SIZE * (xCoord - gridSize * 0.5)}px`}
                top={`-${TILE_SIZE * (effectiveY - gridSize * 0.5)}px`}
                key={`${x}-${y}`}
              />
            ))}
          </div>
        ))}
        {/* overlay a crosshairs to denote the center of the minimap*/}
        <svg
          width={windowSize}
          height={windowSize}
          style={{
            position: 'absolute',
            left: '16px',
            top: '-16px',
          }}
        >
          <line
            x1={windowSize / 2}
            y1={0}
            x2={windowSize / 2}
            y2={windowSize}
            stroke="black"
            strokeWidth={4}
            opacity={0.5}
          />
          <line
            x1={-16}
            y1={windowSize / 2}
            x2={windowSize}
            y2={windowSize / 2}
            stroke="black"
            strokeWidth={4}
            opacity={0.5}
          />
          <circle cx={windowSize / 2} cy={windowSize / 2} r={8} fill="red">
            <animate
              attributeName="opacity"
              values="0;1;0"
              dur="2s"
              repeatCount="indefinite"
            />
          </circle>
        </svg>
        {/* coords in bottom left*/}
        <div
          style={{
            position: 'absolute',
            bottom: '0',
            left: '0',
            padding: '4px',
            backgroundColor: 'rgba(0, 0, 0, 0.5)',
            color: 'white',
          }}
        >
          {`(${xCoord + activeData.tileOffsetX}, ${
            yCoord + activeData.tileOffsetY
          }, ${zCoord})`}
        </div>
      </Window.Content>
    </Window>
  );
};
