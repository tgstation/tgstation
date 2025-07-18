import {
  Box,
  Button,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  satellites: Satellite[];
  meteor_shield: BooleanLike;
  meteor_shield_coverage: number;
  meteor_shield_coverage_max: number;
};

type Satellite = {
  id: string;
  active: BooleanLike;
  mode: string;
};

export const SatelliteControl = (props) => {
  const { data } = useBackend<Data>();
  const { meteor_shield } = data;

  return (
    <Window width={400} height={305}>
      <Window.Content>
        {meteor_shield && <ShieldInfo />}
        <SatelliteDisplay />
      </Window.Content>
    </Window>
  );
};

/** Displays coverage info of the meteor shield */
const ShieldInfo = (props) => {
  const { data } = useBackend<Data>();
  const { meteor_shield_coverage, meteor_shield_coverage_max } = data;

  return (
    <Section>
      <LabeledList>
        <LabeledList.Item label="Coverage">
          <ProgressBar
            value={meteor_shield_coverage / meteor_shield_coverage_max}
            ranges={{
              good: [1, Infinity],
              average: [0.3, 1],
              bad: [-Infinity, 0.3],
            }}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

/** Displays a map of satellites and their status */
const SatelliteDisplay = (props) => {
  const { act, data } = useBackend<Data>();
  const { satellites = [] } = data;

  return (
    <Section title="Satellite Controls">
      <Box mr={-1}>
        {satellites.map((satellite) => (
          <Button.Checkbox
            key={satellite.id}
            checked={satellite.active}
            content={`#${satellite.id} ${satellite.mode}`}
            onClick={() =>
              act('toggle', {
                id: satellite.id,
              })
            }
          />
        ))}
      </Box>
    </Section>
  );
};
