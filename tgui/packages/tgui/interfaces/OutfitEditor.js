import { useBackend } from '../backend';
import { Button, Section, Box, Stack } from '../components';
import { Window } from '../layouts';

export const OutfitEditor = (props, context) => {
  const { act, data } = useBackend(context);
  const { outfit, saveable } = data;

  return (
    <Window
      width={380}
      height={625}>
      <Window.Content>

        <Box
          opacity={0.5}
          py={3}
          position="absolute"
          as="img"
          src={`data:image/jpeg;base64,${data.dummy64}`}
          height="100%"
          width="100%"
          style={{
            '-ms-interpolation-mode': 'nearest-neighbor',
          }} />

        <Section
          fill
          title={
            <>
              {outfit.name}
              <Button
                ml={0.5}
                color="transparent"
                icon="pencil-alt"
                title="Rename this outfit"
                onClick={() => act("rename", {})} />
            </>
          }
          buttons={
            <>
              <Button
                icon="code"
                tooltip="Edit this outfit on a VV window"
                tooltipPosition="left"
                onClick={() => act("vv", {})}
              />
              <Button
                icon="save"
                disabled={!saveable}
                tooltip={!!saveable && "Save this outfit to the custom outfit list"}
                tooltipPosition="left"
                title={!saveable && "This outfit is already on the custom outfit list. Any changes made here will be immediately applied."}
                onClick={() => act("save", {})}
              />
            </>
          }>

          <Box textAlign="center">
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
              <OutfitSlot name="Back" slot="back" />
              <OutfitSlot name="ID" slot="id" />
            </Stack>
            <Stack mb={2}>
              <OutfitSlot name="Belt" slot="belt" />
              <OutfitSlot name="Left Hand" slot="l_hand" />
              <OutfitSlot name="Right Hand" slot="r_hand" />
            </Stack>
            <Stack mb={2}>
              <OutfitSlot name="Shoes" icon="socks" slot="shoes" />
              <OutfitSlot name="Left Pocket" slot="l_pocket" />
              <OutfitSlot name="Right Pocket" slot="r_pocket" />
            </Stack>
          </Box>

        </Section>

      </Window.Content>
    </Window>
  );
};

const OutfitSlot = (props, context) => {
  const { act, data } = useBackend(context);
  const { name, icon, slot } = props;
  const currItem = data.outfit[slot];
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
          title={currItem?.desc}
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
