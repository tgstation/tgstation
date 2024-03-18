import { useBackend, useLocalState } from '../../backend';
import { Button, LabeledList, Section, Stack } from '../../components';

export const TaskManager = (props) => {
  const { act, data } = useBackend();
  const [, setToCall] = useLocalState('toCallTaskInfo');
  const [, setModal] = useLocalState('modal');
  const { tasks } = data;
  const { sleeps = [], yields = [] } = tasks;
  return (
    <Stack fill width="100%" justify="space-around">
      <Stack.Item grow="1" shrink="1">
        <Section title="Sleeps" fill>
          <LabeledList>
            {sleeps.map((info, i) => (
              <LabeledList.Item key={i} label={info.name}>
                <Button
                  color="red"
                  icon="window-close"
                  onClick={() =>
                    act('killTask', { is_sleep: true, index: info.index })
                  }
                >
                  Kill
                </Button>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow="1" shrink="1">
        <Section title="Yields" fill>
          <LabeledList>
            {yields.map((info, i) => (
              <LabeledList.Item key={i} label={info.name}>
                <Button
                  onClick={() => {
                    setToCall({
                      type: 'resumeTask',
                      params: { index: info.index },
                    });
                    setModal('call');
                  }}
                >
                  Call
                </Button>
                <Button
                  color="red"
                  icon="window-close"
                  onClick={() => {
                    act('killTask', { is_sleep: false, index: info.index });
                  }}
                >
                  Kill
                </Button>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
