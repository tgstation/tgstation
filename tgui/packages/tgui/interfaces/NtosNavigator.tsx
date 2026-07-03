import { useState } from 'react';
import { Box, Button, Icon, NoticeBox, Stack } from 'tgui-core/components';
import { useBackend } from '../backend';
import type { Direction } from '../constants';
import { NtosWindow } from '../layouts';
import { type MapData, NanoMap } from './common/NanoMap';

type Data = {
  mapData: MapData;
  location: Location;
  signal: SIGNAL;
};

type Location = {
  x: number;
  y: number;
  z: number;
  dir: Direction;
  area: string;
};

enum SIGNAL {
  LOST = 0,
  LOW = 1,
  GOOD = 2,
}

export function NtosNavigator() {
  const { act, data } = useBackend<Data>();
  const { mapData, location, signal } = data;
  const [currentLevel, setCurrentLevel] = useState<number>(mapData.mainFloor);

  function signalToPos(value: number) {
    if (signal === SIGNAL.LOW) {
      const maxOffset = 5;
      const offset = (Math.random() * 2 - 1) * maxOffset;
      return value + offset;
    }

    return value;
  }

  return (
    <NtosWindow width={665} height={450}>
      <NtosWindow.Content>
        <NanoMap
          minimapDisabled
          buttons={<AreaName name={location?.area} />}
          mapData={mapData}
          onLevelChange={setCurrentLevel}
        >
          {location && signal !== SIGNAL.LOST && (
            <NanoMap.Button
              circular
              selected
              tracking={signal === SIGNAL.GOOD}
              posX={signalToPos(location.x)}
              posY={signalToPos(location.y)}
              posZ={location.z}
              direction={signal === SIGNAL.GOOD && location.dir}
              hidden={location.z !== currentLevel}
              tooltip="Вы тут!"
              tooltipPosition="top"
            />
          )}
          {mapData?.stairs?.map((stair) => (
            <NanoMap.Button
              key={`${stair.posX}-${stair.posY}-${stair.posZ}`}
              posX={stair.posX}
              posY={stair.posY}
              posZ={stair.posZ}
              hidden={stair.posZ !== currentLevel}
              icon="stairs"
              color="blue"
              tooltip={'Лестница'}
              tooltipPosition="top"
              className="stair"
            />
          ))}
        </NanoMap>
        {signal !== SIGNAL.GOOD && <BadSignal signal={signal} />}
      </NtosWindow.Content>
    </NtosWindow>
  );
}

function AreaName(props) {
  const { name } = props;
  return (
    <Box position="fixed" top={6.4} left={4.25}>
      <Button
        fluid
        width="100%"
        style={{ pointerEvents: 'none', textTransform: 'capitalize' }}
      >
        {name}
      </Button>
    </Box>
  );
}

function BadSignal(props) {
  const { signal } = props;
  return (
    <Box
      position="absolute"
      right="0"
      bottom={-0.66}
      left="0"
      style={{ pointerEvents: 'none' }}
    >
      <NoticeBox danger={signal === SIGNAL.LOST}>
        <Stack fill justify="space-between">
          <GpsIcon />
          <Stack.Item>
            {signal === SIGNAL.LOW
              ? 'Нестабильный или крайне слабый сигнал! Местоположение может быть некорректным.'
              : 'Не удаётся определить местоположение устройства! Проверьте качество подключения к NTnet.'}
          </Stack.Item>
          <GpsIcon />
        </Stack>
      </NoticeBox>
    </Box>
  );
}

function GpsIcon() {
  return (
    <Icon.Stack>
      <Icon name={'location-crosshairs'} />
      <Icon name="slash" />
    </Icon.Stack>
  );
}
