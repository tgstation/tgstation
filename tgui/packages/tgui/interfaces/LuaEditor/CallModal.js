import { useBackend, useLocalState } from "../../backend";
import { Button, Modal, Section } from "../../components";
import { ListMapper } from "./ListMapper";

export const CallModal = (props, context) => {
  const { act, data } = useBackend(context);
  const { callArguments } = data;
  const [, setModal] = useLocalState(context, "modal");
  const [toCall, setToCall] = useLocalState(context, "toCallTaskInfo");
  const { type, params } = toCall;
  return (
    <Modal>
      <Section
        height="400px"
        width="300px"
        scrollable
        title="Call Function/Task"
        buttons={(
          <Button
            color="red"
            icon="xmark"
            onClick={() => {
              setModal(null);
              setToCall(null);
              act("clearArgs");
            }}>
            Cancel
          </Button>
        )}>
        <ListMapper
          name="Arguments"
          list={callArguments}
          editable />
        <Button
          onClick={() => {
            setModal(null);
            setToCall(null);
            act(type, params);
          }}>
          Call
        </Button>
      </Section>
    </Modal>
  );
};
