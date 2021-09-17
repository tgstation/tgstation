import { useBackend } from '../backend';
import { Button, Icon, LabeledList, Section } from '../components';
import { Window } from '../layouts';

export const ImplantChair = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window
      width={375}
      height={280}>
      <Window.Content>
        <Section
          title="Occupant Information"
          textAlign="center">
          <LabeledList>
            <LabeledList.Item label="Name">
              {data.occupant.name || 'No Occupant'}
            </LabeledList.Item>
            {!!data.occupied && (
              <LabeledList.Item
                label="Status"
                color={data.occupant.stat === 0
                  ? 'good'
                  : data.occupant.stat === 1
                    ? 'average'
                    : 'bad'}>
                {data.occupant.stat === 0
                  ? 'Conscious'
                  : data.occupant.stat === 1
                    ? 'Unconcious'
                    : 'Dead'}
              </LabeledList.Item>
            )}
          </LabeledList>
        </Section>
        <Section
          title="Operations"
          textAlign="center">
          <LabeledList>
            <LabeledList.Item label="Door">
              <Button
                icon={data.open ? 'unlock' : 'lock'}
                color={data.open ? 'default' : 'red'}
                content={data.open ? 'Open' : 'Closed'}
                onClick={() => act('door')} />
            </LabeledList.Item>
            <LabeledList.Item label="Implant Occupant">
              <Button
                icon="code-branch"
                content={data.ready
                  ? (data.special_name || 'Implant')
                  : 'Recharging'}
                onClick={() => act('implant')} />
              {data.ready === 0 && (
                <Icon
                  name="cog"
                  color="orange"
                  spin />
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Implants Remaining">
              {data.ready_implants}
              {data.replenishing === 1 && (
                <Icon
                  name="sync"
                  color="red"
                  spin />
              )}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
