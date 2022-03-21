import { useBackend } from '../backend';
import { Button, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const TurbineComputer = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={310}
      height={165}>
      <Window.Content>
        <Section
          title="Status"
          buttons={(
            <Button
              icon={data.active ? 'power-off' : 'times'}
              content={data.active ? 'Online' : 'Offline'}
              selected={data.active}
              disabled={!data.can_turn_off}
              onClick={() => act('toggle_power')} />
          )}>
          <LabeledList>
            <LabeledList.Item label="Turbine Damage">
              {data.damage} points
            </LabeledList.Item>
            <LabeledList.Item label="Turbine Speed">
              {data.rpm} RPM
            </LabeledList.Item>
            <LabeledList.Item label="Input Temperature">
              {data.temp} K
            </LabeledList.Item>
            <LabeledList.Item label="Generated Power">
              {data.power * 4} kW
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
