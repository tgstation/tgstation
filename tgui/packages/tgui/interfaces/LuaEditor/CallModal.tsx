import { Dispatch, SetStateAction } from 'react';
import { Button, Modal, Section } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { ListMapper } from './ListMapper';
import { CallInfo, LuaEditorData, LuaEditorModal } from './types';

type CallModalProps = {
  setModal: Dispatch<SetStateAction<LuaEditorModal>>;
  toCall: CallInfo;
  setToCall: Dispatch<SetStateAction<CallInfo | undefined>>;
};

export const CallModal = (props: CallModalProps) => {
  const { act, data } = useBackend<LuaEditorData>();
  const { callArguments } = data;
  const { setModal, toCall, setToCall } = props;
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
              setModal(undefined);
              setToCall(undefined);
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
            setModal(undefined);
            setToCall(undefined);
            act(type, params);
          }}
        >
          Call
        </Button>
      </Section>
    </Modal>
  );
};
