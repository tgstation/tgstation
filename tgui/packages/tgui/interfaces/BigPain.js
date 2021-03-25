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

        <Section fill>
          <Stack mb={2} justify="center">
            <OutfitSlot name="Headgear" slot="head" />
            <OutfitSlot name="Glasses" slot="glasses" />
            <OutfitSlot name="Ears" slot="ears" />
          </Stack>
          <Stack mb={2} justify="center">
            <OutfitSlot name="Neck" slot="neck" />
            <OutfitSlot name="Mask" slot="mask" />
          </Stack>
          <Stack mb={2} justify="center">
            <OutfitSlot name="Uniform" slot="uniform" />
            <OutfitSlot name="Suit" slot="suit" />
            <OutfitSlot name="Gloves" slot="gloves" />
          </Stack>
          <Stack mb={2} justify="center">
            <OutfitSlot name="Suit Storage" slot="suit_store" />
            <OutfitSlot name="Belt" slot="belt" />
            <OutfitSlot name="ID" slot="id" />
          </Stack>
          <Stack mb={2} justify="center">
            <OutfitSlot name="Left Hand" slot="l_hand" />
            <OutfitSlot name="Back" slot="back" />
            <OutfitSlot name="Right Hand" slot="r_hand" />
          </Stack>
          <Stack mb={2} justify="center">
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
  const { name, slot, icon } = props;
  const currItem = data.OutfitSlots[slot];
  return (
    <Stack.Item grow={1} basis={0} textAlign="center">
      <Button icon={icon} fluid height={2}>
        <b>{name}</b>
      </Button>
      <Box
        color="label"
        title={currItem?.path}
        style={{
          'overflow': 'hidden',
          'white-space': 'nowrap',
          'text-overflow': 'ellipsis',
        }}>
        {currItem?.name||"Empty"}
      </Box>
    </Stack.Item>
  );
};
