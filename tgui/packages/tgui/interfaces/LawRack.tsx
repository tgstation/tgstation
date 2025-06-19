import { useState } from 'react';
import {
  Box,
  Button,
  Flex,
  Floating,
  Section,
  Stack,
} from 'tgui-core/components';
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

type Linkable = {
  name: string;
  ref: string;
};

type Data = {
  slots: SlotData[];
  holding_module: BooleanLike;
  holding_screwdriver: BooleanLike;
  holding_welder: BooleanLike;
  holding_multitool: BooleanLike;
  linked: string | null;
  has_core_slot: BooleanLike;
  depowered: BooleanLike;
  allowed: BooleanLike;
  linked_racks?: string[];
  parent_rack?: string;
  linkable_silicons: Linkable[];
  linkable_racks: Linkable[];
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
        <Flex.Item width="8%" mr={1}>
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
        <Flex.Item width="84%">
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
                style={{ textTransform: 'capitalize' }}
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
        <Flex.Item width="8%" ml={1}>
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

const LinkableFloating = (props: {
  linkable: Linkable[];
  link_act: (ref: string) => void;
}) => {
  const { linkable, link_act } = props;

  return (
    <Floating
      stopChildPropagation
      placement="top-start"
      content={
        <Stack vertical>
          {linkable.map((item) => (
            <Stack.Item key={item.ref}>
              <Button
                style={{ textTransform: 'capitalize' }}
                onClick={() => link_act(item.ref)}
              >
                {item.name}
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      }
    />
  );
};

export const LawRack = () => {
  const { data, act } = useBackend<Data>();
  const {
    allowed,
    depowered,
    linkable_racks,
    linkable_silicons,
    linked,
    parent_rack,
    slots,
  } = data;

  const [rackLink, setRackLink] = useState(false);
  const [siliconLink, setSiliconLink] = useState(false);

  return (
    <Window title="Module Rack" width={350} height={600}>
      <Window.Content>
        <Section>
          <Stack vertical>
            {slots.map((slot, index) => (
              <Stack.Item key={index}>
                <LawSlot slot={slot} index={index} />
              </Stack.Item>
            ))}
            <Stack.Divider />
            {linked || parent_rack ? (
              <Stack.Item align="center">
                Linked to <b>{linked || parent_rack}</b>
                <Button
                  ml={1}
                  disabled={!allowed || depowered}
                  icon="link-slash"
                  onClick={() => act(linked ? 'unlink_silicon' : 'unlink_rack')}
                />
              </Stack.Item>
            ) : (
              <Stack.Item align="center">
                <Flex>
                  <Flex.Item>
                    {rackLink && (
                      <LinkableFloating
                        linkable={data.linkable_racks}
                        link_act={(ref) => act('link_rack', { rack_ref: ref })}
                      />
                    )}
                    <Button
                      fluid
                      icon="link"
                      disabled={!data.linkable_racks.length || depowered}
                      tooltip={
                        data.linkable_racks.length
                          ? depowered
                            ? 'No power!'
                            : undefined
                          : 'No linkable racks!'
                      }
                      onClick={() => setRackLink(!rackLink)}
                      mr={0.5}
                    >
                      Link to Core Rack
                    </Button>
                  </Flex.Item>
                  <Flex.Item>
                    {siliconLink && (
                      <LinkableFloating
                        linkable={data.linkable_silicons}
                        link_act={(ref) =>
                          act('link_silicon', { silicon_ref: ref })
                        }
                      />
                    )}
                    <Button
                      fluid
                      icon="link"
                      disabled={!data.linkable_silicons.length || depowered}
                      tooltip={
                        data.linkable_silicons.length
                          ? depowered
                            ? 'No power!'
                            : undefined
                          : 'No linkable silicons!'
                      }
                      onClick={() => setSiliconLink(!siliconLink)}
                      ml={0.5}
                    >
                      Link to Silicon
                    </Button>
                  </Flex.Item>
                </Flex>
              </Stack.Item>
            )}
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
