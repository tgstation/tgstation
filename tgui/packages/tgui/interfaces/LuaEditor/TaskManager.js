import { useBackend, useLocalState } from '../../backend';
import { Button, LabeledList, Section, Stack } from '../../components';

export const TaskManager = (props, context) => {
  const { act, data } = useBackend(context);
  const [, setToCall] = useLocalState(context, 'toCallTaskInfo');
  const [, setModal] = useLocalState(context, 'modal');
  let { tasks } = data;
  tasks?.sort((a, b) => {
    if (a.status < b.status) {
      return -1;
    } else if (a.status > b.status) {
      return 1;
    } else {
      return 0;
    }
  });
  const sleeps = tasks.filter((info) => info.status === 'sleep');
  const yields = tasks.filter((info) => info.status === 'yield');
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
                  onClick={() => act('killTask', { info: info })}>
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
                  }}>
                  Call
                </Button>
                <Button
                  color="red"
                  icon="window-close"
                  onClick={() => {
                    act('killTask', { info: info });
                  }}>
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
