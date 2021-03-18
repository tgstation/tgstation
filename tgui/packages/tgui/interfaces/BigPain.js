import { useBackend } from '../backend';
import { Button, Section, Box, Icon, Stack } from '../components';
import { Window } from '../layouts';

export const BigPain = (props, context) => {
  const { act, data } = useBackend(context);
  const { OutfitSlots } = data;

  const {
    head,
    glasses,
    ears,

    neck,
    mask,

    uniform,
    suit,
    gloves,

    suit_store,
    belt,
    id,

    l_hand,
    back,
    r_hand,

    l_pocket,
    shoes,
    r_pocket,

  } = OutfitSlots;

  return (
    <Window
      width={500}
      height={600}>
      <Window.Content>

        <Section fill>
          <Stack mb={2} justify="center">
            <OutfitSlot slotName="Headgear" currItem={head} />
            <OutfitSlot slotName="Glasses" currItem={glasses} />
            <OutfitSlot slotName="Ears" currItem={ears} />
          </Stack>
          <Stack mb={2} justify="center">
            <OutfitSlot slotName="Neck" currItem={neck} />
            <OutfitSlot slotName="Mask" currItem={mask} />
          </Stack>
          <Stack mb={2} justify="center">
            <OutfitSlot slotName="Uniform" currItem={uniform} />
            <OutfitSlot slotName="Suit" currItem={suit} />
            <OutfitSlot slotName="Gloves" currItem={gloves} />
          </Stack>
          <Stack mb={2} justify="center">
            <OutfitSlot slotName="Suit Storage" currItem={suit_store} />
            <OutfitSlot slotName="Belt" currItem={belt} />
            <OutfitSlot slotName="ID" currItem={id} />
          </Stack>
          <Stack mb={2} justify="center">
            <OutfitSlot slotName="Left Hand" currItem={l_hand} />
            <OutfitSlot slotName="Back" currItem={back} />
            <OutfitSlot slotName="Right Hand" currItem={r_hand} />
          </Stack>
          <Stack mb={2} justify="center">
            <OutfitSlot slotName="Left Pocket" currItem={l_pocket} />
            <OutfitSlot slotName="Shoes" icon="socks" currItem={shoes} />
            <OutfitSlot slotName="Right Pocket" currItem={r_pocket} />
          </Stack>
        </Section>

      </Window.Content>
    </Window>
  );
};

const OutfitSlot = (props, context) => {
  const { act, data } = useBackend(context);
  const { slotName, icon } = props;
  const { currItem } = data[slotName]||"Empty";
  return (
    <Stack.Item grow={1} basis={0} textAlign="center">
      <Button icon={icon} fluid height={2}>
        <b>{slotName}</b>
      </Button>
      <Box
        color="label"
        title={currItem}
        style={{
          'overflow': 'hidden',
          'white-space': 'nowrap',
          'text-overflow': 'ellipsis',
        }}>
        {currItem||"Empty"}
      </Box>
    </Stack.Item>
  );
};
