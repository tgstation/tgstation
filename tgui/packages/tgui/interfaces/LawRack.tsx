import { Box, Button, Flex, Section, Stack } from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

enum SlotSecurity {
  NONE = 0,
  SCREWED = 1,
  WELDED = 2,
}

type SlotData = {
  name: string;
  security: SlotSecurity;
  ioned: BooleanLike;
  empty: BooleanLike;
};

type Data = {
  slots: SlotData[];
  holding_module: BooleanLike;
  holding_screwdriver: BooleanLike;
  holding_welder: BooleanLike;
  holding_multitool: BooleanLike;
  linked: string | null;
  has_core_slot: BooleanLike;
};

function getSlotColor(
  slot: SlotData,
  index: number,
  has_core_slot: BooleanLike,
): string {
  const is_core_slot = index === 0 && has_core_slot;
  if (slot.empty) return is_core_slot ? 'lightsteelblue' : 'lightslategray';
  if (slot.ioned) return 'darkred';
  return is_core_slot ? 'navy' : 'green';
}

const LawSlotScrew = (props: {
  noscrew: boolean;
  disabled: boolean;
  handleScrew: () => void;
}) => {
  return (
    <Button
      width="25px"
      className={props.noscrew ? 'LawRack__Screw Empty' : 'LawRack__Screw'}
      disabled={props.disabled}
      onClick={props.handleScrew}
    />
  );
};

const LawSlot = (props: { slot: SlotData; index: number }) => {
  const { act, data } = useBackend<Data>();

  const { slot, index } = props;
  const {
    holding_module,
    holding_screwdriver,
    holding_welder,
    holding_multitool,
    has_core_slot,
  } = data;

  return (
    <Box
      backgroundColor={getSlotColor(slot, index, has_core_slot)}
      p={1}
      className="LawRack__Slot"
    >
      <Flex>
        <Flex.Item width="10%" mr={1}>
          <LawSlotScrew
            noscrew={slot.empty || slot.security === SlotSecurity.NONE}
            disabled={
              !holding_screwdriver ||
              slot.empty ||
              slot.security === SlotSecurity.WELDED
            }
            handleScrew={() => act('screw_module', { slot: index + 1 })}
          />
        </Flex.Item>
        <Flex.Item width="80%">
          {(slot.security === SlotSecurity.WELDED || !!holding_welder) && (
            <Button
              height="100%"
              textAlign="center"
              verticalAlignContent="middle"
              fluid
              className={
                slot.security === SlotSecurity.WELDED
                  ? 'LawRack__Welded'
                  : undefined
              }
              disabled={!holding_welder || slot.empty}
              onClick={() => act('weld_module', { slot: index + 1 })}
            >
              {slot.security === SlotSecurity.WELDED ? 'Welded' : 'Weld Module'}
            </Button>
          )}
          {slot.security !== SlotSecurity.WELDED && !!holding_multitool && (
            <Button
              height="100%"
              textAlign="center"
              verticalAlignContent="middle"
              fluid
              disabled={!slot.ioned}
              onClick={() => act('multitool_module', { slot: index + 1 })}
            >
              Repair Ion Damage
            </Button>
          )}
          {slot.security !== SlotSecurity.WELDED &&
            !holding_multitool &&
            !holding_welder && (
              <Button
                height="100%"
                textAlign="center"
                verticalAlignContent="middle"
                fluid
                disabled={
                  (!holding_module && slot.empty) ||
                  slot.security !== SlotSecurity.NONE
                }
                onClick={() =>
                  act(
                    holding_module && slot.empty
                      ? 'insert_module'
                      : 'remove_module',
                    { slot: index + 1 },
                  )
                }
              >
                {slot.name || 'Empty'}
              </Button>
            )}
        </Flex.Item>
        <Flex.Item width="10%" ml={1}>
          <LawSlotScrew
            noscrew={slot.empty || slot.security === SlotSecurity.NONE}
            disabled={
              !holding_screwdriver ||
              slot.empty ||
              slot.security === SlotSecurity.WELDED
            }
            handleScrew={() => act('screw_module', { slot: index + 1 })}
          />
        </Flex.Item>
      </Flex>
    </Box>
  );
};

export const LawRack = () => {
  const { data } = useBackend<Data>();
  const { slots, linked } = data;

  return (
    <Window title="Law Rack" width={350} height={600}>
      <Window.Content>
        <Section>
          <Stack vertical>
            {slots.map((slot, index) => (
              <Stack.Item key={index}>
                <LawSlot slot={slot} index={index} />
              </Stack.Item>
            ))}
            <Stack.Divider />
            <Stack.Item align="center">
              {linked ? `Linked to ${linked}` : 'Unlinked'}
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
