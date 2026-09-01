import {
  Button,
  LabeledList,
  NumberInput,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';
import {
  PortableBasicInfo,
  type PortableBasicInfoData,
} from './common/PortableAtmos';

type PortablePumpData = {
  direction: boolean;
  targetPressure: number;
  defaultPressure: number;
  minPressure: number;
  maxPressure: number;
} & PortableBasicInfoData;

export const PortablePump = (props) => {
  const { act, data } = useBackend<PortablePumpData>();
  const {
    direction,
    connected,
    holding,
    targetPressure,
    defaultPressure,
    minPressure,
    maxPressure,
  } = data;
  const pump_or_port = connected ? 'Port' : 'Pump';
  const area_or_tank = holding ? 'Tank' : 'Area';
  return (
    <Window width={300} height={340}>
      <Window.Content>
        <PortableBasicInfo />
        <Section
          title="Pumping"
          buttons={
            <Button
              color={!direction && !holding ? 'caution' : null}
              onClick={() => act('direction')}
            >
              {direction
                ? `${area_or_tank} → ${pump_or_port}`
                : `${pump_or_port} → ${area_or_tank}`}
            </Button>
          }
        >
          <LabeledList>
            <LabeledList.Item label="Output">
              <NumberInput
                value={targetPressure}
                unit="kPa"
                width="75px"
                minValue={minPressure}
                maxValue={maxPressure}
                step={10}
                onChange={(value) =>
                  act('pressure', {
                    pressure: value,
                  })
                }
              />
            </LabeledList.Item>
            <LabeledList.Item label="Presets">
              <Button
                icon="minus"
                disabled={targetPressure === minPressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'min',
                  })
                }
              />
              <Button
                icon="sync"
                disabled={targetPressure === defaultPressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'reset',
                  })
                }
              />
              <Button
                icon="plus"
                disabled={targetPressure === maxPressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'max',
                  })
                }
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
