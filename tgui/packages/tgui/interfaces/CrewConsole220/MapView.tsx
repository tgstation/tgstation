import { useState } from 'react';
import { LabeledList, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { NanoMap } from '../common/NanoMap';
import {
  HEALTH_COLOR_BY_LEVEL,
  healthToAttribute,
  jobIsHead,
  STAT_DEAD,
} from './constants';
import { HealthStat } from './HealthStat';
import type { CrewConsoleData } from './types';

export function MapView(props) {
  const { act, data } = useBackend<CrewConsoleData>();
  const { mapData, sensors } = data;
  const {
    highlight,
    sorted_sensors,
    highlightedSensors,
    searchText,
    headsOnly,
  } = props;
  const [selectedLevel, setSelectedLevel] = useState<number>(mapData.mainFloor);

  return (
    <NanoMap mapData={mapData} onLevelChange={setSelectedLevel}>
      {sensors.map(
        (sensor) =>
          sensor.position?.area !== '~' &&
          sensor.position?.area !== undefined && (
            <NanoMap.Button
              circular
              key={sensor.ref}
              posX={sensor.position?.x}
              posY={sensor.position?.y}
              backgroundColor={healthToAttribute(sensor, HEALTH_COLOR_BY_LEVEL)}
              icon={sensor.life_status === STAT_DEAD && 'skull'}
              tooltip={<CrewMapTooltip sensor_data={sensor} />}
              hidden={
                sensor.position?.z !== selectedLevel ||
                (headsOnly && !jobIsHead(sensor.ijob))
              }
              selected={searchText && sorted_sensors.includes(sensor)}
              highlighted={highlightedSensors.includes(sensor.name)}
              onClick={() => highlight(sensor.name)}
              onContextMenu={(event) => {
                if (props.disabled) {
                  return;
                }

                event.preventDefault();
                act('select_person', {
                  name: sensor.name,
                });
              }}
            />
          ),
      )}
    </NanoMap>
  );
}

const CrewMapTooltip = (props) => {
  const { sensor_data } = props;
  const position = sensor_data.position;
  return (
    <Section
      m={-1}
      title={`${sensor_data.name} (${sensor_data.assignment})`}
      fontSize={0.9}
    >
      <LabeledList>
        <LabeledList.Item
          label="Состояние"
          color={sensor_data.life_status === STAT_DEAD ? '#e74c3c' : '#17d568'}
        >
          {sensor_data.life_status === STAT_DEAD ? 'Мёртв' : 'Живой'}
        </LabeledList.Item>
        <LabeledList.Item label="Здоровье">
          <HealthStat sensor_data={sensor_data} />
        </LabeledList.Item>
        <LabeledList.Item label="Локация">{position?.area}</LabeledList.Item>
        <LabeledList.Item label="Местоположение">
          X: {position?.x}, Y: {position?.y}, Z: {position?.z}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
