import { useState } from 'react';
import { Button, Input, Modal, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { LuaEditorData, LuaEditorModal } from './types';

type StateSelectModalProps = {
  setModal: (modal: LuaEditorModal) => void;
};

export const StateSelectModal = (props: StateSelectModalProps) => {
  const { act, data } = useBackend<LuaEditorData>();
  const { setModal } = props;

  const [input, setInput] = useState('');
  const { states } = data;

  return (
    <Modal position="absolute" width="30%" height="50%" top="25%" left="35%">
      <Section
        fill
        title="States"
        buttons={
          <Button
            color="red"
            icon="window-close"
            onClick={() => {
              setModal(undefined);
            }}
          >
            Cancel
          </Button>
        }
      >
        {states.map((value, i) => (
          <Button
            key={i}
            onClick={() => {
              setModal(undefined);
              act('switchState', { index: i + 1 });
            }}
          >
            {value}
          </Button>
        ))}
        <Stack fill>
          <Stack.Item grow>
            <Input
              fluid
              placeholder="New State"
              value={input}
              onChange={setInput}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="plus"
              onClick={() => {
                setModal(undefined);
                act('newState', { name: input });
              }}
            />
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
};
