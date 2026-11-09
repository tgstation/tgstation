import {
  Box,
  Button,
  DmIcon,
  Flex,
  Section,
  Stack,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  bait_name: string;
  bait_icon: string;
  bait_icon_state: string;
  line_name: string;
  line_icon: string;
  line_icon_state: string;
  hook_name: string;
  hook_icon: string;
  hook_icon_state: string;
  description: string;
};

type Props = {
  name: string;
  slot: string;
  current_item_name: string | null;
  current_item_icon: string | null;
  current_item_icon_state: string | null;
};

const FishingRodSlot = (props: Props) => {
  const { act } = useBackend();
  const {
    current_item_icon,
    current_item_icon_state,
    name,
    slot,
    current_item_name,
  } = props;

  return (
    <Section title={`${name}`}>
      <Stack>
        <Stack.Item grow>
          <Button fluid onClick={() => act('slot_action', { slot: slot })}>
            <Flex>
              <Flex.Item>
                {!!current_item_icon && !!current_item_icon_state && (
                  <DmIcon
                    width="64px" // todo come up with some way to scale this sanely
                    height="64px"
                    icon={current_item_icon}
                    icon_state={current_item_icon_state}
                    verticalAlign="middle"
                  />
                )}
              </Flex.Item>
              <Flex.Item grow align="center">
                <Box textAlign="center">{current_item_name ?? 'None'}</Box>
              </Flex.Item>
            </Flex>
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};

export const FishingRod = (props) => {
  const { data } = useBackend<Data>();
  const {
    bait_name,
    bait_icon,
    bait_icon_state,
    line_name,
    line_icon,
    line_icon_state,
    hook_name,
    hook_icon,
    hook_icon_state,
    description,
  } = data;

  return (
    <Window height={450} width={400}>
      <Window.Content>
        <Section>
          <FishingRodSlot
            name="Bait"
            slot="bait"
            current_item_name={bait_name}
            current_item_icon={bait_icon}
            current_item_icon_state={bait_icon_state}
          />
          <FishingRodSlot
            name="Line"
            slot="line"
            current_item_name={line_name}
            current_item_icon={line_icon}
            current_item_icon_state={line_icon_state}
          />
          <FishingRodSlot
            name="Hook"
            slot="hook"
            current_item_name={hook_name}
            current_item_icon={hook_icon}
            current_item_icon_state={hook_icon_state}
          />
        </Section>
        <Section>{description}</Section>
      </Window.Content>
    </Window>
  );
};
