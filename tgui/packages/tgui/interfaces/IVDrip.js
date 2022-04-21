import { useBackend } from '../backend';
import { Box, Button, NumberInput, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const IVDrip = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    transferRate,
    injectOnly,
    maxInjectRate,
    minInjectRate,
    mode,
    connected,
    beakerAttached,
    useInternalStorage,
  } = data;
  return (
    <Window width={380} height={230}>
      <Window.Content>
        <Section title="IV Status">
          <LabeledList>
            <LabeledList.Item label="Status" color={connected ? 'good' : 'average'}>
              {connected ? "Connected" : "Not Connected"}
            </LabeledList.Item>
            <LabeledList.Item label="Mode">
              <Button
                disabled={injectOnly}
                content={mode ? 'Injecting' : 'Draining'}
                icon={mode ? "sign-in-alt" : "sign-out-alt"}
                onClick={() => act('changeMode')} />
            </LabeledList.Item>
            <LabeledList.Item label="Attached Container" color={beakerAttached ? 'good' : 'average'}>
              <Box as="span" mr={2}>
                {beakerAttached ? "Container Attached" : "Container Not Attached"}
              </Box>
              <Button
                disabled={(!beakerAttached) || useInternalStorage}
                content="Eject"
                icon="eject"
                onClick={() => act('eject')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Injection Settings">
          <LabeledList>
            <LabeledList.Item label="Injection Rate">
              <NumberInput
                value={transferRate}
                unit="u/cycle"
                minValue={minInjectRate}
                maxValue={maxInjectRate}
                step={0.1}
                onChange={(e, value) => act('changeRate', {
                  rate: value,
                })}
              />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
