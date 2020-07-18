import { useBackend } from '../backend';
import { Button, LabeledList, NoticeBox, Section } from '../components';
import { Window } from '../layouts';

export const ProbingConsole = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    open,
    feedback,
    occupant,
    occupant_name,
    occupant_status,
  } = data;
  return (
    <Window
      width={330}
      height={207}
      theme="abductor">
      <Window.Content>
        <Section>
          <LabeledList>
            <LabeledList.Item label="Machine Report">
              {feedback}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section
          title="Scanner"
          buttons={(
            <Button
              icon={open ? 'sign-out-alt' : 'sign-in-alt'}
              content={open ? 'Close' : 'Open'}
              onClick={() => act('door')} />
          )}>
          {occupant && (
            <LabeledList>
              <LabeledList.Item label="Name">
                {occupant_name}
              </LabeledList.Item>
              <LabeledList.Item
                label="Status"
                color={occupant_status === 3
                  ? 'bad'
                  : occupant_status === 2
                    ? 'average'
                    : 'good'}>
                {occupant_status === 3
                  ? 'Deceased'
                  : occupant_status === 2
                    ? 'Unconcious'
                    : 'Concious'}
              </LabeledList.Item>
              <LabeledList.Item label="Experiments">
                <Button
                  icon="thermometer"
                  content="Probe"
                  onClick={() => act('experiment', {
                    experiment_type: 1,
                  })} />
                <Button
                  icon="brain"
                  content="Dissect"
                  onClick={() => act('experiment', {
                    experiment_type: 2,
                  })} />
                <Button
                  icon="search"
                  content="Analyze"
                  onClick={() => act('experiment', {
                    experiment_type: 3,
                  })} />
              </LabeledList.Item>
            </LabeledList>
          ) || (
            <NoticeBox>
              No Subject
            </NoticeBox>
          )}
        </Section>
      </Window.Content>
    </Window>
  );
};
