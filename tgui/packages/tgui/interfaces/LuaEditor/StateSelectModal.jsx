import { useBackend, useLocalState } from '../../backend';
import { Button, Input, Modal, Section, Stack } from '../../components';

export const StateSelectModal = (props) => {
  const { act, data } = useBackend();
  const [, setModal] = useLocalState('modal', 'states');
  const [input, setInput] = useLocalState('newStateName', '');
  const { states } = data;
  return (
    <Modal
      height={`${window.innerHeight * 0.5}px`}
      width={`${window.innerWidth * 0.3}px`}
    >
      <Section
        fill
        title="States"
        buttons={
          <Button
            color="red"
            icon="window-close"
            onClick={() => {
              setModal(null);
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
              setModal(null);
              act('switchState', { index: i + 1 });
            }}
          >
            {value}
          </Button>
        ))}
        <Stack fill>
          <Stack.Item shrink basis="100%">
            <Input
              fluid
              placeholder="New State"
              value={input}
              onInput={(_, value) => {
                setInput(value);
              }}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="plus"
              onClick={() => {
                setModal(null);
                act('newState', { name: input });
              }}
            />
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
};
