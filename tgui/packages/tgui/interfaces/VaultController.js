import { toFixed } from 'common/math';
import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section } from '../components';

export const VaultController = props => {
  const { act, data } = useBackend(props);
  return (
    <Section
      title="Lock Status: "
      buttons={(
        <Button
          content={data.doorstatus ? 'Locked' : 'Unlocked'}
          icon={data.doorstatus ? 'lock' : 'unlock'}
          disabled={data.stored < data.max}
          onClick={() => act('togglelock')} />
      )}>
      <LabeledList>
        <LabeledList.Item label="Charge">
          <ProgressBar
            value={data.stored / data.max}
            content={toFixed(data.stored/1000)
              + ' / ' + toFixed(data.max/1000) + ' kW'}
            ranges={{
              good: [1, Infinity],
              average: [0.30, 1],
              bad: [-Infinity, 0.30],
            }} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
