import { useBackend, useLocalState } from "../../backend";
import { Button, Modal, Input, Section, Stack } from "../../components";

export const StateSelectModal = (props, context) => {
  const { act, data } = useBackend(context);
  const [, setModal] = useLocalState(context, "modal", "states");
  const [input, setInput] = useLocalState(context, "newStateName", "");
  const { states } = data;
  return (
    <Modal>
      <Section
        height="400px"
        width="300px"
        title="States"
        buttons={(
          <Button
            color="red"
            icon="window-close"
            onClick={() => {
              setModal(null);
            }}>
            Cancel
          </Button>
        )}>
        {states.map((value, i) => (
          <Button
            key={i}
            onClick={() => {
              setModal(null);
              act("switchState", { index: i+1 });
            }}>
            {value}
          </Button>
        ))}
        <Stack>
          <Stack.Item>
            <Input
              width="250px"
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
                act("newState", { name: input });
              }}
            />
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
};
