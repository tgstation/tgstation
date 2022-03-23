import { useBackend, useLocalState } from "../../backend";
import { Button, Modal, Input, Section, Stack } from "../../components";

export const ContextSelectModal = (props, context) => {
  const { act, data } = useBackend(context);
  const [, setModal] = useLocalState(context, "modal", "contexts");
  const [input, setInput] = useLocalState(context, "newContextName", "");
  const { contexts } = data;
  return (
    <Modal>
      <Section
        height="400px"
        width="300px"
        title="Contexts"
        buttons={(
          <Button
            color="red"
            icon="xmark"
            onClick={() => {
              setModal(null);
            }}>
            Cancel
          </Button>
        )}>
        {contexts.map((value, i) => (
          <Button
            key={i}
            onClick={() => {
              setModal(null);
              act("switchContext", { index: i+1 });
            }}>
            {value}
          </Button>
        ))}
        <Stack>
          <Stack.Item>
            <Input
              width="250px"
              fluid
              placeholder="New Context"
              value={input}
              onInput={(_, value) => {
                setInput(value);
              }}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="file-plus"
              onClick={() => {
                setModal(null);
                act("newContext", { name: input });
              }}
            />
          </Stack.Item>
        </Stack>
      </Section>
    </Modal>
  );
};
