import { useState } from 'react';
import {
  BlockQuote,
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
  has_core_slot: BooleanLike;
  depowered: BooleanLike;
  allowed: BooleanLike;
  parent_rack?: Linkable;
  linkable_silicons: Linkable[];
  linkable_racks: Linkable[];
  linked_racks?: Record<string, number>;
  linked_mobs: Record<string, number>;
  refresh_cooldown: number;
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
  noscrew: BooleanLike;
  disabled: BooleanLike;
  tooltip?: string;
  handleScrew: () => void;
}) => {
  return (
    <Button
      tooltip={props.tooltip}
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
      height="33px"
      backgroundColor={getSlotColor(slot, index, has_core_slot)}
      p={1}
      mb={-0.5}
      className="LawRack__Slot"
    >
      <Flex align="center">
        <Flex.Item mr={1}>
          <LawSlotScrew
            tooltip={
              slot.security === SlotSecurity.SCREWED && !holding_screwdriver
                ? 'You need a screwdriver to unscrew this module.'
                : holding_screwdriver && slot.security === SlotSecurity.WELDED
                  ? `You can't remove the screws before unwelding it.`
                  : undefined
            }
            noscrew={slot.empty || slot.security === SlotSecurity.NONE}
            disabled={
              !holding_screwdriver ||
              slot.empty ||
              slot.security === SlotSecurity.WELDED
            }
            handleScrew={() => act('screw_module', { slot: index + 1 })}
          />
        </Flex.Item>
        <Flex.Item width="85%">
          {(slot.security === SlotSecurity.WELDED || !!holding_welder) && (
            <Button
              textAlign="center"
              verticalAlignContent="middle"
              fluid
              tooltip={
                slot.security === SlotSecurity.WELDED && !holding_welder
                  ? `You can't remove this module before unwelding it.`
                  : holding_welder &&
                      slot.security === SlotSecurity.NONE &&
                      !slot.empty
                    ? 'Screw this module in place before welding.'
                    : undefined
              }
              className={
                slot.security === SlotSecurity.WELDED
                  ? 'LawRack__Welded'
                  : undefined
              }
              disabled={
                !holding_welder ||
                slot.empty ||
                slot.security === SlotSecurity.NONE
              }
              onClick={() => act('weld_module', { slot: index + 1 })}
            >
              {slot.security === SlotSecurity.WELDED
                ? 'Welded'
                : slot.empty
                  ? slot.name || 'Empty'
                  : 'Weld Module'}
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
                tooltip={
                  slot.security === SlotSecurity.SCREWED
                    ? `You can't remove this module before unscrewing it.`
                    : undefined
                }
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
        <Flex.Item ml={1}>
          <LawSlotScrew
            tooltip={
              slot.security === SlotSecurity.SCREWED && !holding_screwdriver
                ? 'You need a screwdriver to unscrew this module.'
                : holding_screwdriver && slot.security === SlotSecurity.WELDED
                  ? `You can't remove the screws before unwelding it.`
                  : undefined
            }
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
  show_floating: boolean;
  linkable: Linkable[];
  link_act: (ref: string, name: string) => void;
  button: React.ReactNode;
}) => {
  const { show_floating, linkable, link_act, button } = props;

  if (!show_floating) {
    return button;
  }

  return (
    <Floating
      stopChildPropagation
      placement="top-start"
      content={
        <Stack
          vertical
          backgroundColor="black"
          p={1}
          style={{
            borderRadius: '4px',
            boxShadow: '0px 4px 8px 3px rgba(0, 0, 0, 0.7)',
          }}
        >
          {linkable.map((item) => (
            <Stack.Item key={item.ref}>
              <Button
                style={{ textTransform: 'capitalize' }}
                onClick={() => link_act(item.ref, item.name)}
              >
                Link to: <b>{item.name}</b>
              </Button>
            </Stack.Item>
          ))}
        </Stack>
      }
    >
      {button}
    </Floating>
  );
};

export const LawRack = () => {
  const { data, act } = useBackend<Data>();
  const {
    allowed,
    depowered,
    linkable_racks,
    linkable_silicons,
    linked_mobs,
    linked_racks,
    parent_rack,
    slots,
    refresh_cooldown,
  } = data;

  const [rackLink, setRackLink] = useState(true);
  const [siliconLink, setSiliconLink] = useState(true);

  return (
    <Window title="Module Rack" width={330} height={slots.length * 40 + 100}>
      <Window.Content>
        <Section>
          <Stack vertical>
            {slots.map((slot, index) => (
              <Stack.Item key={index}>
                <LawSlot slot={slot} index={index} />
              </Stack.Item>
            ))}
          </Stack>
        </Section>
        <Section
          buttons={
            <Button
              icon="refresh"
              disabled={depowered || refresh_cooldown > 0}
              tooltipPosition="left"
              tooltip={
                depowered
                  ? 'No power!'
                  : refresh_cooldown > 0
                    ? `Cooldown: ${refresh_cooldown / 10}s`
                    : undefined
              }
              onClick={() => act('refresh')}
            />
          }
        >
          <Stack.Item align="center">
            <Flex align="center">
              {!!linked_mobs.length && (
                <Flex.Item>
                  <Stack vertical>
                    <Stack.Item>Linked Silicons:</Stack.Item>
                    {Object.entries(linked_mobs).map(
                      ([name, list_index], index) => (
                        <Stack.Item key={index}>
                          <Button
                            fluid
                            mr={1}
                            icon="link-slash"
                            disabled={!allowed || depowered}
                            tooltipPosition="right"
                            tooltip={
                              !allowed
                                ? `You lack the access to unlink silicons.`
                                : depowered
                                  ? 'No power!'
                                  : undefined
                            }
                            onClick={() =>
                              act('unlink_silicon', {
                                silicon_index: list_index,
                              })
                            }
                          />
                          <BlockQuote>{name}</BlockQuote>
                        </Stack.Item>
                      ),
                    )}
                  </Stack>
                </Flex.Item>
              )}
              {!!linked_racks?.length && (
                <Flex.Item>
                  <Stack vertical>
                    <Stack.Item>Linked Racks:</Stack.Item>
                    {Object.entries(linked_racks).map(
                      ([name, list_index], index) => (
                        <Stack.Item key={index}>
                          <Button
                            fluid
                            mr={1}
                            icon="link-slash"
                            disabled={!allowed || depowered}
                            tooltipPosition="right"
                            tooltip={
                              !allowed
                                ? `You lack the access to unlink child racks.`
                                : depowered
                                  ? 'No power!'
                                  : undefined
                            }
                            onClick={() =>
                              act('unlink_rack', { rack_index: list_index })
                            }
                          />
                          <BlockQuote>{name}</BlockQuote>
                        </Stack.Item>
                      ),
                    )}
                  </Stack>
                </Flex.Item>
              )}
              {parent_rack ? (
                <Flex.Item>
                  <Button
                    fluid
                    icon="link-slash"
                    disabled={depowered}
                    tooltipPosition="right"
                    tooltip={depowered ? 'No power!' : undefined}
                    onClick={() => act('unlink_parent_rack')}
                  />
                  <BlockQuote>
                    Linked to: <b>{parent_rack.name}</b>
                  </BlockQuote>
                </Flex.Item>
              ) : (
                <>
                  <Flex.Item>
                    <LinkableFloating
                      show_floating={rackLink}
                      linkable={linkable_racks}
                      link_act={(ref, name) =>
                        act('link_rack', { rack_ref: ref, rack_name: name })
                      }
                      button={
                        <Button
                          fluid
                          icon="link"
                          disabled={!linkable_racks.length || depowered}
                          tooltip={
                            linkable_racks.length
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
                      }
                    />
                  </Flex.Item>
                  <Flex.Item>
                    <LinkableFloating
                      show_floating={siliconLink}
                      linkable={linkable_silicons}
                      link_act={(ref, name) =>
                        act('link_silicon', {
                          silicon_ref: ref,
                          silicon_name: name,
                        })
                      }
                      button={
                        <Button
                          fluid
                          icon="link"
                          disabled={!linkable_silicons.length || depowered}
                          tooltip={
                            linkable_silicons.length
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
                      }
                    />
                  </Flex.Item>
                </>
              )}
            </Flex>
          </Stack.Item>
        </Section>
      </Window.Content>
    </Window>
  );
};
