import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, Section, NoticeBox, LabeledList, ProgressBar } from '../components';
import { act } from '../byond';

export const Pool = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
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
    <Fragment>
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
          onClick={() => act(ref, 'raise_temp')} />
        <Button
          content="Decrease temperature"
          disabled={data.timer}
          icon="minus"
          onClick={() => act(ref, 'lower_temp')} />
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
          onClick={() => act(ref, 'toggle_drain')} />
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
          onClick={() => act(ref, 'remove_beaker')} />
      </Section>
    </Fragment>); };