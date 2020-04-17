import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Box, Button, LabeledList, NumberInput, ProgressBar, Section } from '../components';

export const Electrolyzer = props => {
  const { act, data } = useBackend(props);
  return (
    <Section
      title="Power"
      buttons={(
        <Fragment>
          <Button
            icon="eject"
            content="Eject Cell"
            disabled={!data.hasPowercell || !data.open}
            onClick={() => act('eject')} />
          <Button
            icon={data.on ? 'power-off' : 'times'}
            content={data.on ? 'On' : 'Off'}
            selected={data.on}
            disabled={!data.hasPowercell}
            onClick={() => act('power')} />
        </Fragment>
      )}>
      <LabeledList>
        <LabeledList.Item
          label="Cell"
          color={!data.hasPowercell && 'bad'}>
          {data.hasPowercell && (
            <ProgressBar
              value={data.powerLevel / 100}
              content={data.powerLevel + '%'}
              ranges={{
                good: [0.6, Infinity],
                average: [0.3, 0.6],
                bad: [-Infinity, 0.3],
              }} />
          ) || 'None'}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
