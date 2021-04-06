import { useBackend } from '../backend';
import { Button, Section, Box, Stack, Icon } from '../components';
import { Window } from '../layouts';

export const OutfitEditor = (props, context) => {
  const { act, data } = useBackend(context);
  const { outfit, saveable, dummy64 } = data;

  return (
    <Window
      width={380}
      height={625}>
      <Window.Content>
        <Box
          as="img"
          fillPositionedParent
          width="100%"
          height="100%"
          opacity={0.5}
          py={3}
          src={`data:image/jpeg;base64,${dummy64}`}
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
                color="transparent"
                icon="info"
                // tooltips are wack with a lot of text; forced to use title
                title="Ctrl-click a button to select *any* item instead of what will probably fit in that slot." />
              <Button
                icon="code"
                tooltip="Edit this outfit on a VV window"
                tooltipPosition="left"
                onClick={() => act("vv", {})} />
              <Button
                icon="save"
                disabled={!saveable}
                tooltip={!!saveable && "Save this outfit to the custom outfit list"}
                tooltipPosition="left"
                title={!saveable && "This outfit is already on the custom outfit list. Any changes made here will be immediately applied."}
                onClick={() => act("save", {})} />
            </>
          }>
          <Box textAlign="center">
            <Stack mb={2}>
              <OutfitSlot name="Headgear" icon="hard-hat" slot="head" />
              <OutfitSlot name="Glasses" icon="glasses" slot="glasses" />
              <OutfitSlot name="Ears" icon="headphones-alt" slot="ears" />
            </Stack>
            <Stack mb={2}>
              <OutfitSlot name="Neck" icon="stethoscope" slot="neck" />
              <OutfitSlot name="Mask" icon="theater-masks" slot="mask" />
            </Stack>
            <Stack mb={2}>
              <OutfitSlot name="Uniform" icon="tshirt" slot="uniform" />
              <OutfitSlot name="Suit" icon="user-tie" slot="suit" />
              <OutfitSlot name="Gloves" icon="mitten" slot="gloves" />
            </Stack>
            <Stack mb={2}>
              <OutfitSlot name="Suit Storage" slot="suit_store" />
              <OutfitSlot name="Back" slot="back" />
              <OutfitSlot name="ID" icon="id-card-o" slot="id" />
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
  const { outfit } = data;
  const currItem = outfit[slot];
  return (
    <Stack.Item grow={1} basis={0}>
      <Button fluid height={2}
        bold
        icon={icon}
        // todo: intuitive way to clear items
        onClick={e => act(e.ctrlKey ? "ctrlClick" : "click", { slot })} >
        {name}
      </Button>
      <Box height="32px">
        {currItem?.sprite && (
          <Box
            as="img"
            src={`data:image/jpeg;base64,${currItem?.sprite}`}
            title={currItem?.desc}
            style={{
              '-ms-interpolation-mode': 'nearest-neighbor',
            }} />
        )}
      </Box>
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
