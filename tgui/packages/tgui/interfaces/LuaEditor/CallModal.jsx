import { useBackend, useLocalState } from '../../backend';
import { Button, Modal, Section } from '../../components';
import { ListMapper } from './ListMapper';

export const CallModal = (props) => {
  const { act, data } = useBackend();
  const { callArguments } = data;
  const [, setModal] = useLocalState('modal');
  const [toCall, setToCall] = useLocalState('toCallTaskInfo');
  const { type, params } = toCall;
  return (
    <Modal
      height={`${window.innerHeight * 0.8}px`}
      width={`${window.innerWidth * 0.5}px`}
    >
      <Section
        fill
        scrollable
        scrollableHorizontal
        title="Call Function/Task"
        buttons={
          <Button
            color="red"
            icon="window-close"
            onClick={() => {
              setModal(null);
              setToCall(null);
              act('clearArgs');
            }}
          >
            Cancel
          </Button>
        }
      >
        <ListMapper name="Arguments" list={callArguments} editable />
        <Button
          onClick={() => {
            setModal(null);
            setToCall(null);
            act(type, params);
          }}
        >
          Call
        </Button>
      </Section>
    </Modal>
  );
};
