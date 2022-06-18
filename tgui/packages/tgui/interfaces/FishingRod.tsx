import { useBackend } from '../backend';
import { Window } from '../layouts';
import { Box, Stack, Button, Section, Flex } from '../components';


type Quality = {
  name: string,
  kind: "good" | "neutral" | "medium"
}

type FishingRodData = {
    bait_name: string,
    bait_icon: string,
    line_name: string,
    line_icon: string,
    hook_name: string,
    hook_icon: string
    description: string,
}


type FishingSlotProps = {
  name : string,
  slot: string,
  current_item_name: string | null,
  current_item_icon: string | null
}


const FishingRodSlot = (props: FishingSlotProps, context) => {
  const { act } = useBackend(context);

  const icon_wrapper = icon => (<Box
    as="img"
    width="64px" // todo come up with some way to scale this sanely
    height="64px"
    src={`data:image/jpeg;base64,${icon}`}
    style={{
      "-ms-interpolation-mode": "nearest-neighbor",
      "vertical-align": "middle",
      "object-fit": "cover",
    }} />);

  return (
    <Section title={`${props.name}`}>
      <Stack>
        <Stack.Item grow>
          <Button fluid
            onClick={() => act("slot_action", { slot: props.slot })}>
            <Flex>
              <Flex.Item>
                {!!props.current_item_icon
                  && icon_wrapper(props.current_item_icon)}
              </Flex.Item>
              <Flex.Item grow align="center">
                <Box textAlign="center">{props.current_item_name ?? "None"}</Box>
              </Flex.Item>
            </Flex>
          </Button>
        </Stack.Item>
      </Stack>
    </Section>);
};

export const FishingRod = (props, context) => {
  const { act, data } = useBackend<FishingRodData>(context);

  return (
    <Window>
      <Window.Content>
        <Section>
          <FishingRodSlot
            name="Bait"
            slot="bait"
            current_item_name={data.bait_name}
            current_item_icon={data.bait_icon}
          />
          <FishingRodSlot
            name="Line"
            slot="line"
            current_item_name={data.line_name}
            current_item_icon={data.line_icon}
          />
          <FishingRodSlot
            name="Hook"
            slot="hook"
            current_item_name={data.hook_name}
            current_item_icon={data.hook_icon}
          />
        </Section>
        <Section>
          {data.description}
        </Section>
      </Window.Content>
    </Window>
  );
};

