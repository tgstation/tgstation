import { useState } from 'react';
import {
  Box,
  Button,
  DmIcon,
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
  if (slot.empty) return is_core_slot ? '#5AA6FF' : '#83BFB1';
  if (slot.ioned) return '#DD7973';
  return is_core_slot ? '#4183CD' : '#14BB69';
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
  hide_floating: () => void;
  button: React.ReactNode;
}) => {
  const { show_floating, linkable, link_act, button, hide_floating } = props;

  if (!show_floating) {
    return button;
  }

  return (
    <Floating
      stopChildPropagation
      placement="top-start"
      content={
        <Stack
          fill
          backgroundColor="black"
          p={1}
          style={{
            borderRadius: '4px',
            boxShadow: '0px 4px 8px 3px rgba(0, 0, 0, 0.7)',
            flexDirection: 'column',
          }}
        >
          {linkable.map((item) => (
            <Stack.Item key={item.ref}>
              <Button
                icon="link"
                style={{ textTransform: 'capitalize' }}
                onClick={() => {
                  link_act(item.ref, item.name);
                  if (linkable.length === 1) hide_floating();
                }}
              >
                <b>{item.name}</b>
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

const UnlinkableFloating = (props: {
  show_floating: boolean;
  unlinkable: Record<string, number>;
  unlink_act: (index: number, name: string) => void;
  hide_floating: () => void;
  button: React.ReactNode;
  can_unlink: BooleanLike;
  unlink_tooltip?: string;
}) => {
  const {
    button,
    can_unlink,
    hide_floating,
    show_floating,
    unlink_act,
    unlink_tooltip,
    unlinkable,
  } = props;

  if (!show_floating) {
    return button;
  }

  return (
    <Floating
      stopChildPropagation
      placement="top-start"
      content={
        <Stack
          fill
          backgroundColor="black"
          p={1}
          style={{
            borderRadius: '4px',
            boxShadow: '0px 4px 8px 3px rgba(0, 0, 0, 0.7)',
            flexDirection: 'column',
          }}
        >
          {Object.entries(unlinkable).map(([name, list_index], index) => (
            <Stack.Item key={name + list_index}>
              <Button
                icon="link-slash"
                style={{ textTransform: 'capitalize' }}
                disabled={!can_unlink}
                tooltip={unlink_tooltip}
                onClick={() => {
                  unlink_act(list_index, name);
                  if (Object.entries(unlinkable).length === 1) hide_floating();
                }}
              >
                <b>{name}</b>
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

const AiFlavorDisplay = (props: { show_face: string }) => {
  return (
    <Box style={{ display: 'grid' }}>
      <DmIcon
        icon="icons/obj/machines/status_display.dmi"
        icon_state="entertainment_frame"
        height="90px"
        width="80px"
      />
      {!!props.show_face && (
        <DmIcon
          icon="icons/obj/machines/status_display.dmi"
          icon_state={props.show_face}
          height="90px"
          width="80px"
          position="absolute"
        />
      )}
    </Box>
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

  const [rackUnlink, setRackUnlink] = useState(true);
  const [siliconUnlink, setSiliconUnlink] = useState(true);

  const screen_display = () => {
    if (depowered) {
      return 'off';
    }
    if (parent_rack || Object.entries(linked_mobs).length) {
      return Math.round(Math.random() * 100) === 1 ? 'ai_hal' : 'ai_sal';
    }
    return 'ai_bsod';
  };

  return (
    <Window title="Module Rack" width={400} height={slots.length * 36 + 250}>
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
          title="Controls"
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
                    : 'Refreshes possible linkable racks and silicons.'
              }
              onClick={() => act('refresh')}
            />
          }
        >
          <Flex>
            <Flex.Item mr={1} width="39%">
              <Stack vertical>
                <Stack.Item align="center" bold>
                  Rack Connections
                </Stack.Item>
                {linked_racks && !!Object.entries(linked_racks).length ? (
                  <Stack.Item>
                    <UnlinkableFloating
                      show_floating={rackUnlink}
                      unlinkable={linked_racks}
                      can_unlink={!depowered && allowed}
                      unlink_tooltip={
                        depowered
                          ? 'No power!'
                          : allowed
                            ? undefined
                            : 'You lack sufficent access to unlink racks!'
                      }
                      unlink_act={(index, name) =>
                        act('unlink_rack', {
                          rack_index: index,
                          rack_name: name,
                        })
                      }
                      hide_floating={() => setRackUnlink(false)}
                      button={
                        <Button
                          align="center"
                          width="100%"
                          disabled={
                            depowered || !Object.entries(linked_racks).length
                          }
                          tooltip={
                            depowered
                              ? 'No power!'
                              : Object.entries(linked_racks).length
                                ? undefined
                                : 'No linked racks!'
                          }
                          onClick={() => setRackUnlink(!rackUnlink)}
                        >
                          View Linked Racks
                        </Button>
                      }
                    />
                  </Stack.Item>
                ) : parent_rack ? (
                  <Stack.Item>
                    <UnlinkableFloating
                      show_floating={rackUnlink}
                      unlinkable={{ [parent_rack.name]: 0 }}
                      can_unlink={!depowered && allowed}
                      unlink_tooltip={
                        depowered
                          ? 'No power!'
                          : allowed
                            ? undefined
                            : 'You lack sufficent access to unlink racks!'
                      }
                      unlink_act={() => act('unlink_parent_rack')}
                      hide_floating={() => setRackUnlink(false)}
                      button={
                        <Button
                          align="center"
                          width="100%"
                          disabled={depowered}
                          tooltipPosition="right"
                          tooltip={depowered ? 'No power!' : undefined}
                          onClick={() => setRackUnlink(!rackUnlink)}
                        >
                          View Linked Racks
                        </Button>
                      }
                    />
                  </Stack.Item>
                ) : (
                  <Stack.Item>
                    <Button
                      align="center"
                      width="100%"
                      disabled
                      tooltip={depowered ? 'No power!' : 'No linked racks!'}
                    >
                      View Linked Racks
                    </Button>
                  </Stack.Item>
                )}
                <Stack.Item>
                  <LinkableFloating
                    show_floating={rackLink}
                    linkable={linkable_racks}
                    link_act={(ref, name) =>
                      act('link_rack', { rack_ref: ref, rack_name: name })
                    }
                    hide_floating={() => setRackLink(false)}
                    button={
                      <Button
                        align="center"
                        width="100%"
                        disabled={
                          !linkable_racks.length || depowered || !!parent_rack
                        }
                        tooltip={
                          depowered
                            ? 'No power!'
                            : linkable_racks.length
                              ? parent_rack
                                ? 'Already linked!'
                                : undefined
                              : 'No linkable racks!'
                        }
                        onClick={() => setRackLink(!rackLink)}
                      >
                        New Link
                      </Button>
                    }
                  />
                </Stack.Item>
              </Stack>
            </Flex.Item>
            <Flex.Item width="22%">
              <AiFlavorDisplay show_face={screen_display()} />
            </Flex.Item>
            <Flex.Item ml={0.5} width="39%">
              <Stack vertical>
                <Stack.Item align="center" bold>
                  Connected Silicons
                </Stack.Item>
                <UnlinkableFloating
                  show_floating={siliconUnlink}
                  unlinkable={linked_mobs}
                  can_unlink={!depowered && allowed}
                  unlink_tooltip={
                    depowered
                      ? 'No power!'
                      : allowed
                        ? undefined
                        : 'You lack sufficent access to unlink silicons!'
                  }
                  unlink_act={(index, name) =>
                    act('unlink_silicon', {
                      silicon_index: index,
                      silicon_name: name,
                    })
                  }
                  hide_floating={() => setSiliconUnlink(false)}
                  button={
                    <Button
                      align="center"
                      width="100%"
                      disabled={
                        !Object.entries(linked_mobs).length || depowered
                      }
                      tooltip={
                        depowered
                          ? 'No power!'
                          : Object.entries(linked_mobs).length
                            ? undefined
                            : 'No linked silicons!'
                      }
                      onClick={() => setSiliconUnlink(!siliconUnlink)}
                    >
                      View Connections
                    </Button>
                  }
                />
                <Stack.Item>
                  <LinkableFloating
                    show_floating={siliconLink}
                    linkable={linkable_silicons}
                    link_act={(ref, name) =>
                      act('link_silicon', {
                        silicon_ref: ref,
                        silicon_name: name,
                      })
                    }
                    hide_floating={() => setSiliconLink(false)}
                    button={
                      <Button
                        align="center"
                        width="100%"
                        disabled={
                          !linkable_silicons.length ||
                          depowered ||
                          !!parent_rack
                        }
                        tooltip={
                          depowered
                            ? 'No power!'
                            : linkable_silicons.length
                              ? parent_rack
                                ? 'Linked to another rack!'
                                : undefined
                              : 'No linkable silicons!'
                        }
                        onClick={() => setSiliconLink(!siliconLink)}
                      >
                        New Connection
                      </Button>
                    }
                  />
                </Stack.Item>
              </Stack>
            </Flex.Item>
          </Flex>
        </Section>
      </Window.Content>
    </Window>
  );
};
