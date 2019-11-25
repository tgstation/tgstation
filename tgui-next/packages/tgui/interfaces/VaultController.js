import { toFixed } from 'common/math';
import { act } from '../byond';
import { Button, LabeledList, ProgressBar, Section } from '../components';

export const VaultController = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Section
      title="Lock Status: "
      buttons={(
        <Button
          content={data.doorstatus ? 'Locked' : 'Unlocked'}
          icon={data.doorstatus ? 'lock' : 'unlock'}
          disabled={data.stored < data.max}
          onClick={() => act(ref, 'togglelock')}
        />
      )}>
      <LabeledList>
        <LabeledList.Item label="Charge">
          <ProgressBar
            value={data.stored / data.max}
            content={toFixed(data.stored/1000) + ' / ' + data.max/1000 + ' kW'}
            ranges={{
              good: [1, Infinity],
              average: [0.30, 1],
              bad: [-Infinity, 0.30],
            }}
          />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
