import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, LabeledList, ProgressBar, Section } from '../components';
import { Window } from '../layouts';
import { logger } from '../logging';

export const MODSuit = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={400}
      height={300}
      theme="ntos"
      title="MOD Interface Panel"
      resizable>
      <Window.Content>
        <Section title="Parameters">
          <LabeledList>
            <LabeledList.Item label="Status">
              {data.malfunction ? 'Malfunctioning' : data.active ? 'Active' : 'Inactive'}
            </LabeledList.Item>
            <LabeledList.Item
              label="Cell Charge"
              color={!data.cell && 'bad'}>
              {data.cell && (
                <ProgressBar
                  value={data.charge / 100}
                  content={data.charge + '%'}
                  ranges={{
                    good: [0.6, Infinity],
                    average: [0.3, 0.6],
                    bad: [-Infinity, 0.3],
                  }} />
              ) || 'None'}
            </LabeledList.Item>
            <LabeledList.Item label="Cell">
              {data.cell}
            </LabeledList.Item>
            <LabeledList.Item label="Occupant">
              {data.wearer_name}, {data.wearer_job}
            </LabeledList.Item>
            <LabeledList.Item label="Onboard AI">
              {data.AI ? data.AI : "None"}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Options">
          <Button
            icon="power-off"
            content={data.active ? 'Deactivate Suit' : 'Activate Suit'}
            onClick={() => act('activate')} />
          <Button
            icon={data.locked ? "lock-open" : "lock"}
            content={data.locked ? 'Unlock' : 'Lock'}
            onClick={() => act('lock')} />
        </Section>
      </Window.Content>
    </Window>
  );
};
