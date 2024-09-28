import { useState } from 'react';

import { useBackend } from '../../backend';
import {
  Button,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
} from '../../components';
import { PodData } from './types';

export default function PodDisplay(_props: any): JSX.Element {
  const { act, data } = useBackend<PodData>();
  const {
    name,
    power,
    maxPower,
    health,
    acceleration,
    maxAcceleration,
    forcePerMove,
    cabinPressure,
    headlightsEnabled,
    occupantcount,
    occupantmax,
  } = data;

  const [editing, setEditing] = useState(false);

  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          title={
            editing ? (
              <Input
                fluid
                value={name}
                placeholder="Name..."
                onChange={(_e: any, value: string) =>
                  act('change-name', { newName: value })
                }
              />
            ) : (
              name
            )
          }
          buttons={
            <Button
              icon="pen-to-square"
              selected={editing}
              onClick={() => setEditing(!editing)}
            />
          }
        >
          <LabeledList>
            <LabeledList.Item label="Health">
              <ProgressBar
                value={health}
                ranges={{
                  good: [0.5, Infinity],
                  average: [0.25, 0.5],
                  bad: [-Infinity, 0.25],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Item label="Power">
              <ProgressBar
                value={power}
                minValue={0}
                maxValue={maxPower}
                ranges={{
                  good: [0.5, Infinity],
                  average: [0.25, 0.5],
                  bad: [-Infinity, 0.25],
                }}
              />
            </LabeledList.Item>
            <LabeledList.Divider />
            <LabeledList.Item label="Cabin Pressure">
              {cabinPressure}
            </LabeledList.Item>
            <LabeledList.Item label="Occupants">
              {occupantcount} / {occupantmax}
            </LabeledList.Item>
            <LabeledList.Item label="Acceleration">
              {acceleration} / {maxAcceleration} ({forcePerMove}N/s)
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Button
          fluid
          py="0.5rem"
          textAlign="center"
          fontSize="1.2rem"
          fontWeight="bold"
          selected={!!headlightsEnabled}
          icon={`lightbulb${headlightsEnabled ? '' : '-o'}`}
          onClick={() => act('toggle-headlights')}
        >
          {headlightsEnabled ? 'Disable Headlights' : 'Enable Headlights'}
        </Button>
      </Stack.Item>
    </Stack>
  );
}
