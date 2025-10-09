import { Box, Button, Icon, Image, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const OutfitEditor = (props) => {
  const { act, data } = useBackend();
  const { outfit, saveable, dummy64 } = data;
  return (
    <Window width={380} height={600} theme="admin">
      <Window.Content>
        <Image
          fillPositionedParent
          width="100%"
          height="100%"
          opacity={0.5}
          py={3}
          src={`data:image/jpeg;base64,${dummy64}`}
        />
        <Section
          fill
          title={
            <Stack>
              <Stack.Item
                grow={1}
                style={{
                  overflow: 'hidden',
                  whiteSpace: 'nowrap',
                  textOverflow: 'ellipsis',
                }}
              >
                <Button
                  ml={0.5}
                  color="transparent"
                  icon="pencil-alt"
                  title="Rename this outfit"
                  onClick={() => act('rename', {})}
                />
                {outfit.name}
              </Stack.Item>
              <Stack.Item align="end" shrink={0}>
                <Button
                  color="transparent"
                  icon="info"
                  tooltip="Ctrl-click a button to select *any* item instead of what will probably fit in that slot."
                  tooltipPosition="bottom-start"
                />
                <Button
                  icon="code"
                  tooltip="Edit this outfit on a VV window"
                  tooltipPosition="bottom-start"
                  onClick={() => act('vv')}
                />
                <Button
                  color={!saveable && 'bad'}
                  icon={saveable ? 'save' : 'trash-alt'}
                  tooltip={
                    saveable
                      ? 'Save this outfit to the custom outfit list'
                      : 'Remove this outfit from the custom outfit list'
                  }
                  tooltipPosition="bottom-start"
                  onClick={() => act(saveable ? 'save' : 'delete')}
                />
              </Stack.Item>
            </Stack>
          }
        >
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
              <OutfitSlot
                name="Suit Storage"
                icon="briefcase-medical"
                slot="suit_store"
              />
              <OutfitSlot name="Back" icon="shopping-bag" slot="back" />
              <OutfitSlot name="ID" icon="id-card-o" slot="id" />
            </Stack>
            <Stack mb={2}>
              <OutfitSlot name="Belt" icon="band-aid" slot="belt" />
              <OutfitSlot name="Left Hand" icon="hand-paper" slot="l_hand" />
              <OutfitSlot name="Right Hand" icon="hand-paper" slot="r_hand" />
            </Stack>
            <Stack mb={2}>
              <OutfitSlot name="Shoes" icon="socks" slot="shoes" />
              <OutfitSlot
                name="Left Pocket"
                icon="envelope-open-o"
                iconRot={180}
                slot="l_pocket"
              />
              <OutfitSlot
                name="Right Pocket"
                icon="envelope-open-o"
                iconRot={180}
                slot="r_pocket"
              />
            </Stack>
          </Box>
        </Section>
      </Window.Content>
    </Window>
  );
};

const OutfitSlot = (props) => {
  const { act, data } = useBackend();
  const { name, icon, iconRot, slot } = props;
  const { outfit } = data;
  const currItem = outfit[slot];
  return (
    <Stack.Item grow={1} basis={0}>
      <Button
        fluid
        height={2}
        bold
        // todo: intuitive way to clear items
        onClick={(e) => act(e.ctrlKey ? 'ctrlClick' : 'click', { slot })}
      >
        <Icon name={icon} rotation={iconRot} mr={0.5} />
        {name}
      </Button>
      <Box height="32px">
        {currItem?.sprite && (
          <>
            <Image
              src={`data:image/jpeg;base64,${currItem?.sprite}`}
              title={currItem?.desc}
            />
            <Icon
              position="absolute"
              name="times"
              color="label"
              style={{ cursor: 'pointer' }}
              onClick={() => act('clear', { slot })}
            />
          </>
        )}
      </Box>
      <Box
        color="label"
        style={{
          overflow: 'hidden',
          whiteSpace: 'nowrap',
          textOverflow: 'ellipsis',
        }}
        title={currItem?.path}
      >
        {currItem?.name || 'Empty'}
      </Box>
    </Stack.Item>
  );
};
