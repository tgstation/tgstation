import { useBackend } from '../backend';
import { Button, Section, Box, Icon, Stack } from '../components';
import { Window } from '../layouts';

export const BigPain = (props, context) => {
  const { act, data } = useBackend(context);

  return (
    <Window
      width={500}
      height={600}>
      <Window.Content>

        <Section fill textAlign="center">
          <Stack mb={2}>
            <OutfitSlot name="Headgear" slot="head" />
            <OutfitSlot name="Glasses" slot="glasses" />
            <OutfitSlot name="Ears" slot="ears" />
          </Stack>
          <Stack mb={2}>
            <OutfitSlot name="Neck" slot="neck" />
            <OutfitSlot name="Mask" slot="mask" />
          </Stack>
          <Stack mb={2}>
            <OutfitSlot name="Uniform" slot="uniform" />
            <OutfitSlot name="Suit" slot="suit" />
            <OutfitSlot name="Gloves" slot="gloves" />
          </Stack>
          <Stack mb={2}>
            <OutfitSlot name="Suit Storage" slot="suit_store" />
            <OutfitSlot name="Belt" slot="belt" />
            <OutfitSlot name="ID" slot="id" />
          </Stack>
          <Stack mb={2}>
            <OutfitSlot name="Left Hand" slot="l_hand" />
            <OutfitSlot name="Back" slot="back" />
            <OutfitSlot name="Right Hand" slot="r_hand" />
          </Stack>
          <Stack>
            <OutfitSlot name="Left Pocket" slot="l_pocket" />
            <OutfitSlot name="Shoes" icon="socks" slot="shoes" />
            <OutfitSlot name="Right Pocket" slot="r_pocket" />
          </Stack>
        </Section>

      </Window.Content>
    </Window>
  );
};

const OutfitSlot = (props, context) => {
  const { act, data } = useBackend(context);
  const { name, icon, slot } = props;
  const currItem = data.OutfitSlots[slot];
  return (
    <Stack.Item grow={1} basis={0}>
      <Button fluid height={2}
        icon={icon}
        onClick={() => act("click", { slot: slot })}>
        <b>{name}</b>
      </Button>
      {currItem?.sprite && (
        <Box
          as="img"
          src={`data:image/jpeg;base64,${currItem?.sprite}`}
          height="32px"
          style={{
            '-ms-interpolation-mode': 'nearest-neighbor',
          }} />
      )||(
        <Box height="32px" />
      )}
      <Box
        color="label"
        style={{
          'overflow': 'hidden',
          'white-space': 'nowrap',
          'text-overflow': 'ellipsis',
        }}
        title={currItem?.path}>
        {currItem?.name||"Empty"}
      </Box>
    </Stack.Item>
  );
};
