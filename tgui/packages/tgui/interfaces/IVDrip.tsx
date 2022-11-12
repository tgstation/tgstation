import { BooleanLike } from 'common/react';
import { useBackend } from '../backend';
import { Box, Button, NumberInput, LabeledList, Section } from '../components';
import { Window } from '../layouts';

type IVDripData = {
  transferRate: number;
  injectOnly: BooleanLike;
  minInjectRate: number;
  maxInjectRate: number;
  mode: BooleanLike;
  connected: BooleanLike;
  beakerAttached: BooleanLike;
  useInternalStorage: BooleanLike;
};

export const IVDrip = (props, context) => {
  const { act, data } = useBackend<IVDripData>(context);
  return (
    <Window width={380} height={230}>
      <Window.Content>
        <Section title="IV Status">
          <LabeledList>
            <LabeledList.Item
              label="Status"
              color={data.connected ? 'good' : 'average'}>
              {data.connected ? 'Connected' : 'Not Connected'}
            </LabeledList.Item>
            <LabeledList.Item label="Mode">
              <Button
                disabled={data.injectOnly}
                content={data.mode ? 'Injecting' : 'Draining'}
                icon={data.mode ? 'sign-in-alt' : 'sign-out-alt'}
                onClick={() => act('changeMode')}
              />
            </LabeledList.Item>
            <LabeledList.Item
              label="Attached Container"
              color={data.beakerAttached ? 'good' : 'average'}>
              <Box as="span" mr={2}>
                {data.beakerAttached
                  ? 'Container Attached'
                  : 'Container Not Attached'}
              </Box>
              <Button
                disabled={!data.beakerAttached || data.useInternalStorage}
                content="Eject"
                icon="eject"
                onClick={() => act('eject')}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Injection Settings">
          <LabeledList>
            <LabeledList.Item label="Injection Rate">
              <NumberInput
                value={data.transferRate}
                unit="u/sec"
                minValue={data.minInjectRate}
                maxValue={data.maxInjectRate}
                step={0.1}
                onChange={(e, value) =>
                  act('changeRate', {
                    rate: value,
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
