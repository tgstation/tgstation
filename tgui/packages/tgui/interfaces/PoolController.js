import { useBackend } from '../backend';
import { Box, Button, Section, NoticeBox, LabeledList, ProgressBar } from '../components';
import { Window } from '../layouts';

export const PoolController = (props, context) => {
  // const { state } = props;
  const { act, data } = useBackend(context);
  // const { ref } = config;
  const poolTemp = {
    5: {
      color: 'bad',
      content: 'Scalding',
    },
    4: {
      color: 'good',
      content: 'Warm',
    },
    3: {
      color: 'good',
      content: 'Normal',
    },
    2: {
      color: 'good',
      content: 'Cool',
    },
    1: {
      color: 'bad',
      content: 'Freezing',
    },
  };
  const temperature = poolTemp[data.temperature] || poolTemp[0];
  return (
    <Window>
      <Window.Content>
        <NoticeBox>
          The lock out timer displays: {data.timer}
        </NoticeBox>
        <Section title="Temperature">
          <LabeledList>
            <LabeledList.Item
              label="Current Temperature"
              color={temperature.color}
              content={temperature.content} />
          </LabeledList>
          <Button
            content="Increase temperature"
            disabled={data.timer}
            icon="plus"
            onClick={() => act('raise_temp')} />
          <Button
            content="Decrease temperature"
            disabled={data.timer}
            icon="minus"
            onClick={() => act('lower_temp')} />
        </Section>
        <Section title="Drain">
          <LabeledList>
            <LabeledList.Item
              label="Drain status"
              color={data.drainable ? 'bad' : 'good'}
              content={data.drainable ? "Enabled" : "Disabled"} />
            <LabeledList.Item
              label="Pool status"
              color={data.poolstatus ? 'bad' : 'good'}
              content={data.poolstatus ? "Drained" : "Full"} />
          </LabeledList>
          <Button
            content={data.poolstatus ? "Fill Pool" : "Drain Pool"}
            disabled={data.timer}
            onClick={() => act('toggle_drain')} />
        </Section>
        <Section title="Chemistry">
          <LabeledList>
            <LabeledList.Item
              label="Current Reagent"
              content={data.reagent} />
          </LabeledList>
          <Button
            icon="eject"
            content="Remove Beaker"
            disabled={(data.hasBeaker === null) || data.timer}
            onClick={() => act('remove_beaker')} />
        </Section>
      </Window.Content>
    </Window>
  );
};
