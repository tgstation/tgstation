import {
  Button,
  DmIcon,
  Flex,
  ProgressBar,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  stacks: Stacks[];
  repairbot_icon: string;
  repairbot_icon_state: string;
};

type Stacks = {
  stack_name: string;
  stack_amount: number;
  stack_maximum_amount: number;
  stack_icon: string;
  stack_icon_state: string;
  stack_reference: string;
};

export const RepairbotResources = (props) => {
  const { act, data } = useBackend<Data>();
  const { stacks, repairbot_icon, repairbot_icon_state } = data;
  return (
    <Window title="Resource Management" width={405} height={260} theme="ntos">
      <Window.Content>
        <Section
          fill
          title="Resource Management"
          textAlign="center"
          scrollable
          buttons={
            <DmIcon
              mt={-5.7}
              icon={repairbot_icon}
              icon_state={repairbot_icon_state}
              height="96px"
              width="96px"
            />
          }
        >
          <Stack wrap>
            {stacks.map((stack) => (
              <Stack.Item
                ml={1}
                mt={1}
                key={stack.stack_reference}
                style={{
                  background: 'rgba(36, 50, 67, 0.5)',
                  padding: '5px 5px',
                  borderRadius: '2em',
                  border: '2px solid #574e82',
                }}
              >
                <Flex>
                  <Flex.Item>
                    <DmIcon
                      style={{ borderRadius: '1em', background: '#151326' }}
                      icon={stack.stack_icon}
                      icon_state={stack.stack_icon_state}
                      height="48px"
                      width="48px"
                    />
                  </Flex.Item>
                  <Flex.Item ml={1}>
                    <Stack vertical height="65px">
                      <Stack.Item width="100px" mt={1.5}>
                        <ProgressBar
                          value={stack.stack_amount}
                          maxValue={stack.stack_maximum_amount}
                          color="green"
                        />
                      </Stack.Item>
                      <Stack.Item>
                        <Button
                          width="75px"
                          style={{
                            padding: '3px',
                            borderRadius: '1em',
                            background: '#151326',
                          }}
                          onClick={() =>
                            act('eject', {
                              item_reference: stack.stack_reference,
                            })
                          }
                        >
                          Eject
                        </Button>
                      </Stack.Item>
                    </Stack>
                  </Flex.Item>
                </Flex>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
