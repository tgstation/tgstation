import { JSX, useState } from 'react';
import { Button, NoticeBox, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { Window } from '../../layouts';
import { AnimateArgumentsModal } from './arguments_modal';

type SetActiveModalFunc = React.Dispatch<
  React.SetStateAction<ActiveModalFunc | undefined>
>;
type ActiveModalFunc = (setActiveModal: SetActiveModalFunc) => JSX.Element;

export function AnimationDebugPanel() {
  const { data, act } = useBackend<AnimationDebugPanelData>();

  const [activeModal, setActiveModal] = useState<ActiveModalFunc | undefined>(
    undefined,
  );

  if (activeModal) {
    return activeModal;
  }

  return (
    <Window title="Animation Debug Panel">
      <NoticeBox danger>TODO</NoticeBox>
      <Stack>
        <Stack.Item grow>
          <ChainView />
        </Stack.Item>
        <Stack.Item grow>
          <AnimationArguments setActiveModal={setActiveModal} />
        </Stack.Item>
      </Stack>
    </Window>
  );
}

function getChainByIndex(index: number) {
  const { data } = useBackend<AnimationDebugPanelData>();
  const { chain } = data;
  if (!chain) return undefined;
  let current: AnimateChain | undefined = chain;
  while (current && current.chain_index !== index) {
    current = chain.next;
  }
  return chain;
}

function ChainView() {
  const [currentChain, setCurrentChain] = useState(0);
  const chain = getChainByIndex(currentChain);
  return <Section />;
}

function AnimationArguments(props: { setActiveModal: SetActiveModalFunc }) {
  const { data, act } = useBackend<AnimationDebugPanelData>();
  return (
    <Section
      title="Arguments"
      buttons={
        <Stack>
          <Stack.Item>
            <Button
              icon="plus"
              color="green"
              tooltip="Add"
              onClick={() => act('arguments-add')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="trash"
              color="yellow"
              tooltip="Clear"
              onClick={() => act('arguments-wipe')}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon="trash"
              color="blue"
              tooltip="Help"
              onClick={() => props.setActiveModal(AnimateArgumentsModal)}
            />
          </Stack.Item>
        </Stack>
      }
    >
      <Stack vertical />
    </Section>
  );
}
