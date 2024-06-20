import { toFixed } from 'common/math';

import { useBackend } from '../backend';
import {
  Button,
  LabeledControls,
  NumberInput,
  RoundGauge,
  Section,
} from '../components';
import { formatSiUnit } from '../format';
import { Window } from '../layouts';

const formatPressure = (value) => {
  if (value < 10000) {
    return toFixed(value) + ' kPa';
  }
  return formatSiUnit(value * 1000, 1, 'Pa');
};

export const Tank = (props) => {
  const { act, data } = useBackend();
  const {
    defaultReleasePressure,
    minReleasePressure,
    maxReleasePressure,
    leakPressure,
    fragmentPressure,
    tankPressure,
    releasePressure,
    connected,
  } = data;
  return (
    <Window width={275} height={120}>
      <Window.Content>
        <Section>
          <LabeledControls>
            <LabeledControls.Item label="Pressure">
              <RoundGauge
                value={tankPressure}
                minValue={0}
                maxValue={fragmentPressure * 1.15}
                alertAfter={leakPressure}
                ranges={{
                  good: [0, leakPressure],
                  average: [leakPressure, fragmentPressure],
                  bad: [fragmentPressure, fragmentPressure * 1.15],
                }}
                format={formatPressure}
                size={2}
              />
            </LabeledControls.Item>
            <LabeledControls.Item label="Pressure Regulator">
              <Button
                icon="fast-backward"
                disabled={data.ReleasePressure === data.minReleasePressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'min',
                  })
                }
              />
              <NumberInput
                animated
                value={parseFloat(data.releasePressure)}
                width="65px"
                unit="kPa"
                step={1}
                minValue={data.minReleasePressure}
                maxValue={data.maxReleasePressure}
                onChange={(value) =>
                  act('pressure', {
                    pressure: value,
                  })
                }
              />
              <Button
                icon="fast-forward"
                disabled={data.ReleasePressure === data.maxReleasePressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'max',
                  })
                }
              />
              <Button
                icon="undo"
                content=""
                disabled={data.ReleasePressure === data.defaultReleasePressure}
                onClick={() =>
                  act('pressure', {
                    pressure: 'reset',
                  })
                }
              />
            </LabeledControls.Item>
          </LabeledControls>
        </Section>
      </Window.Content>
    </Window>
  );
};
