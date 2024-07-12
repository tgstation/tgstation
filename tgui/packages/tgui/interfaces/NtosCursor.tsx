import { useState } from 'react';

import { useBackend } from '../backend';
import { Button, DmIcon, NoticeBox, Section, Stack } from '../components';
import { NtosWindow } from '../layouts';

type Data = {
  dmi: {
    icon: string;
    icon_state: string;
  };
};

export const NtosCursor = () => {
  const { data } = useBackend<Data>();

  const { dmi } = data;

  const [numClicked, incrementClicked] = useState(0);

  const NoticeBoxText = () => {
    if (numClicked <= 2) {
      return `There's only one option... It's the sword.`;
    } else if (numClicked === 3) {
      return `You clicked the sword. It's still the sword.`;
    } else if (numClicked === 4) {
      return `You clicked the sword again. It's still the sword.`;
    } else if (numClicked === 5) {
      return `Trying to click the sword again? It's still the sword.`;
    }
    return `You clicked the sword ${numClicked} times... It's still the sword.`;
  };

  return (
    <NtosWindow width={350} height={300}>
      <NtosWindow.Content scrollable>
        <Section title="Select Cursor">
          <Stack vertical>
            <Stack.Item align={'center'}>
              <Button
                height="100px"
                width="100px"
                color={numClicked >= 1 ? 'green' : null}
                onClick={() => incrementClicked(numClicked + 1)}
              >
                <DmIcon
                  icon={dmi.icon}
                  icon_state={dmi.icon_state}
                  style={{
                    transform: `scale(3) translateX(4px) translateY(8px)`,
                  }}
                />
              </Button>
            </Stack.Item>
            <Stack.Item>
              <NoticeBox>{NoticeBoxText()}</NoticeBox>
            </Stack.Item>
          </Stack>
        </Section>
      </NtosWindow.Content>
    </NtosWindow>
  );
};
