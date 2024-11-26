import { useBackend } from '../../../backend';
import {
  Box,
  Button,
  Dimmer,
  DmIcon,
  Flex,
  Icon,
  LabeledList,
  Section,
  Stack,
} from '../../../components';
import { FAIcon, LoadoutItem, LoadoutManagerData, ReskinOption } from './base';
import { ItemIcon } from './ItemDisplay';

// Used in LoadoutItem to make buttons relating to how an item can be edited
export type LoadoutButton = {
  label: string;
  act_key?: string;
  button_icon?: FAIcon;
  button_text?: string;
  active_key?: string;
  active_text?: string;
  inactive_text?: string;
  tooltip_text?: string;
};

const LoadoutModifyButton = (props: {
  button: LoadoutButton;
  modifyItemDimmer: LoadoutItem;
}) => {
  const { act, data } = useBackend<LoadoutManagerData>();
  const { loadout_list } = data.character_preferences.misc;
  const { button, modifyItemDimmer } = props;

  const buttonIsActive =
    button.active_key && loadout_list[modifyItemDimmer.path][button.active_key];

  if (button.active_text && button.inactive_text) {
    return (
      <Button.Checkbox
        tooltip={button.tooltip_text}
        checked={buttonIsActive}
        color={buttonIsActive ? 'green' : 'default'}
        onClick={() => {
          act('pass_to_loadout_item', {
            subaction: button.act_key,
            path: modifyItemDimmer.path,
          });
        }}
      >
        {buttonIsActive ? button.active_text : button.inactive_text}
      </Button.Checkbox>
    );
  }

  return (
    <Button
      icon={button.button_icon}
      tooltip={button.tooltip_text}
      disabled={!button.act_key}
      color={buttonIsActive ? 'green' : 'default'}
      onClick={() => {
        act('pass_to_loadout_item', {
          subaction: button.act_key,
          path: modifyItemDimmer.path,
        });
      }}
    >
      {button.button_text}
    </Button>
  );
};

const LoadoutModifyButtons = (props: { modifyItemDimmer: LoadoutItem }) => {
  const { act, data } = useBackend<LoadoutManagerData>();
  const { loadout_list } = data.character_preferences.misc;
  const { modifyItemDimmer } = props;

  const isActive = (item: LoadoutItem, reskin: ReskinOption) => {
    return loadout_list && loadout_list[item.path]['reskin']
      ? loadout_list[item.path]['reskin'] === reskin.name
      : item.icon_state === reskin.skin_icon_state;
  };

  return (
    <Stack>
      <Stack.Item>
        <LabeledList>
          {!!modifyItemDimmer.reskins && (
            <LabeledList.Item label="Styles" verticalAlign="middle">
              <Flex wrap width="50%">
                {modifyItemDimmer.reskins.map((reskin) => (
                  <Flex.Item key={reskin.tooltip} mr={1} mb={1}>
                    <Button
                      tooltip={reskin.tooltip}
                      color={
                        isActive(modifyItemDimmer, reskin) ? 'green' : 'default'
                      }
                      onClick={() => {
                        act('pass_to_loadout_item', {
                          subaction: 'set_skin',
                          path: modifyItemDimmer.path,
                          skin: reskin.name,
                        });
                      }}
                    >
                      {modifyItemDimmer.icon ? (
                        <DmIcon
                          fallback={<Icon name="spinner" spin color="gray" />}
                          icon={modifyItemDimmer.icon}
                          icon_state={reskin.skin_icon_state}
                          style={{
                            transform: `scale(2) translateY(2px)`,
                          }}
                        />
                      ) : (
                        // Should never happen, hopefully
                        <Box>{reskin.name}</Box>
                      )}
                    </Button>
                  </Flex.Item>
                ))}
              </Flex>
            </LabeledList.Item>
          )}
          {modifyItemDimmer.buttons.map((button) => (
            <LabeledList.Item key={button.label} label={button.label}>
              <LoadoutModifyButton
                button={button}
                modifyItemDimmer={modifyItemDimmer}
              />
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
};

const LoadoutModifyItemDisplay = (props: { modifyItemDimmer: LoadoutItem }) => {
  const { modifyItemDimmer } = props;
  return (
    <Stack vertical justify="center">
      <Stack.Item>
        <Box bold width="80px" textAlign="center">
          {modifyItemDimmer.name}
        </Box>
      </Stack.Item>
      <Stack.Item ml={-0.5}>
        <ItemIcon item={modifyItemDimmer} scale={3} />
      </Stack.Item>
    </Stack>
  );
};

export const LoadoutModifyDimmer = (props: {
  modifyItemDimmer: LoadoutItem;
  setModifyItemDimmer: (dimmer: LoadoutItem | null) => void;
}) => {
  const { act } = useBackend();
  const { modifyItemDimmer, setModifyItemDimmer } = props;
  return (
    <Dimmer style={{ zIndex: '100' }}>
      <Stack
        vertical
        width="400px"
        backgroundColor="#101010"
        style={{
          borderRadius: '2px',
          position: 'relative',
          display: 'inline-block',
          padding: '5px',
        }}
      >
        <Stack.Item height="20px">
          <Flex justify="flex-end">
            <Flex.Item>
              <Button
                icon="times"
                color="red"
                onClick={() => {
                  setModifyItemDimmer(null);
                  act('close_greyscale_menu');
                }}
              />
            </Flex.Item>
          </Flex>
        </Stack.Item>
        <Stack.Item width="100%" height="100%">
          <Flex>
            <Flex.Item mr={1}>
              <Section width="90px" height="160px">
                <LoadoutModifyItemDisplay modifyItemDimmer={modifyItemDimmer} />
              </Section>
            </Flex.Item>
            <Flex.Item width="310px">
              <Section fill>
                <LoadoutModifyButtons modifyItemDimmer={modifyItemDimmer} />
              </Section>
            </Flex.Item>
          </Flex>
        </Stack.Item>
        <Stack.Item>
          <Stack justify="center">
            <Button
              onClick={() => {
                setModifyItemDimmer(null);
                act('close_greyscale_menu');
              }}
            >
              Done
            </Button>
          </Stack>
        </Stack.Item>
      </Stack>
    </Dimmer>
  );
};
