import { Dispatch, SetStateAction } from 'react';
import { Button, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { CallInfo, LuaEditorData, LuaEditorModal } from './types';

type TaskManagerProps = {
  setToCall: Dispatch<SetStateAction<CallInfo>>;
  setModal: Dispatch<SetStateAction<LuaEditorModal>>;
};

export const TaskManager = (props: TaskManagerProps) => {
  const { act, data } = useBackend<LuaEditorData>();
  const { setToCall, setModal } = props;
  const { tasks } = data;
  const { sleeps = [], yields = [] } = tasks;
  return (
    <Stack fill width="100%" justify="space-around">
      <Stack.Item grow shrink>
        <Section title="Sleeps" fill>
          <LabeledList>
            {sleeps.map(({ index, name }, i) => (
              <LabeledList.Item key={i} label={name}>
                <Button
                  color="red"
                  icon="window-close"
                  onClick={() =>
                    act('killTask', { is_sleep: true, index: index })
                  }
                >
                  Kill
                </Button>
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow shrink>
        <Section title="Yields" fill>
          <LabeledList>
            {yields.map(({ index, name }, i) => (
              <LabeledList.Item key={i} label={name}>
                <Button
                  onClick={() => {
                    setToCall({
                      type: 'resumeTask',
                      params: { index: index },
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
                    act('killTask', { is_sleep: false, index: index });
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
