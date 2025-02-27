// THIS IS A DOPPLER SHIFT UI FILE
import {
  BlockQuote,
  Box,
  Button,
  Collapsible,
  Divider,
  Flex,
  LabeledList,
  ProgressBar,
  Section,
} from 'tgui-core/components';

import { useBackend } from '../backend';
import { Window } from '../layouts';

export const Soulcatcher = (props) => {
  const { act, data } = useBackend();
  const {
    require_approval,
    current_rooms = [],
    ghost_joinable,
    current_soul_count,
    max_souls,
    removable,
    communicate_as_parent,
    theme,
  } = data;

  return (
    <Window width={520} height={400} theme={theme} resizable>
      <Window.Content scrollable>
        {current_rooms.map((room) => (
          <Section
            key={room.key}
            title={<span style={{ color: room.color }}>{room.name}</span>}
            buttons={
              <>
                <Button
                  icon="palette"
                  tooltip="Change the color of the room"
                  onClick={() =>
                    act('change_room_color', { room_ref: room.reference })
                  }
                >
                  Recolor
                </Button>
                <Button
                  icon="pen"
                  tooltip="Change the name of the room"
                  onClick={() =>
                    act('rename_room', { room_ref: room.reference })
                  }
                >
                  Rename
                </Button>
                <Button
                  icon="trash"
                  tooltip="Delete the room"
                  color="red"
                  onClick={() =>
                    act('delete_room', { room_ref: room.reference })
                  }
                >
                  Delete
                </Button>
              </>
            }
          >
            <BlockQuote preserveWhitespace> {room.description}</BlockQuote>
            <Box>
              <Button
                icon="scroll"
                tooltip="Performs an emote, without sending a name."
                onClick={() =>
                  act('send_message', {
                    room_ref: room.reference,
                    emote: true,
                    narration: true,
                  })
                }
              >
                Narrate
              </Button>

              <Button
                icon="comment"
                tooltip="Speak inside of the room."
                onClick={() =>
                  act('send_message', {
                    room_ref: room.reference,
                    emote: false,
                  })
                }
              >
                Say
              </Button>

              <Button
                icon="face-smile"
                tooltip="Do an emote inside of the room."
                onClick={() =>
                  act('send_message', {
                    room_ref: room.reference,
                    emote: true,
                  })
                }
              >
                Emote
              </Button>

              <Button
                icon="user-gear"
                tooltip="Edits the name that is sent when emoting and saying."
                onClick={() =>
                  act('modify_name', {
                    room_ref: room.reference,
                  })
                }
              >
                Edit Name
              </Button>
              <Button
                icon="book"
                tooltip="Changes the description of the room"
                onClick={() =>
                  act('redescribe_room', { room_ref: room.reference })
                }
              >
                Redecorate
              </Button>
              <Button
                color={room.joinable ? 'green' : 'red'}
                icon={room.joinable ? 'door-open' : 'door-closed'}
                onClick={() =>
                  act('toggle_joinable_room', { room_ref: room.reference })
                }
              >
                {room.joinable ? 'Room joinable' : 'Room unjoinable'}
              </Button>
              <Button
                icon={room.currently_targeted ? 'check' : 'xmark'}
                tooltip="Choose where messages using the soulcatcher verbs are sent."
                color={room.currently_targeted ? 'green' : 'red'}
                onClick={() =>
                  act('change_targeted_room', { room_ref: room.reference })
                }
              >
                {room.currently_targeted ? 'Targeted' : 'Untargeted'}
              </Button>
            </Box>
            {room.souls ? (
              <>
                <br />
                <Box textAlign="center" fontSize="15px" opacity={0.8}>
                  <b>Current Souls</b>
                </Box>
                <Divider />
                <Flex direction="column">
                  {room.souls.map((soul) => (
                    <Flex.Item key={soul.key}>
                      <Collapsible
                        title={soul.name}
                        buttons={
                          <>
                            {soul.scan_needed ? (
                              <> </>
                            ) : (
                              <>
                                <Button
                                  color="green"
                                  icon="pen"
                                  tooltip="Change the soul's name."
                                  onClick={() =>
                                    act('change_name', {
                                      target_soul: soul.reference,
                                      room_ref: room.reference,
                                    })
                                  }
                                />
                                <Button
                                  color="red"
                                  icon="arrow-rotate-left"
                                  tooltip="Reset the soul's name."
                                  onClick={() =>
                                    act('reset_name', {
                                      target_soul: soul.reference,
                                      room_ref: room.reference,
                                    })
                                  }
                                />
                              </>
                            )}
                            <Button
                              icon="paper-plane"
                              tooltip="Transfer a soul to another room"
                              onClick={() =>
                                act('transfer_soul', {
                                  room_ref: room.reference,
                                  target_soul: soul.reference,
                                })
                              }
                            />
                          </>
                        }
                      >
                        <Box textAlign="center" fontSize="13px" opacity={0.8}>
                          <b>Flavor Text</b>
                        </Box>
                        <Divider />
                        <BlockQuote preserveWhitespace>
                          {soul.description}
                        </BlockQuote>
                        <br />
                        <Box textAlign="center" fontSize="13px" opacity={0.8}>
                          <b>OOC Notes</b>
                        </Box>
                        <Divider />
                        <BlockQuote preserveWhitespace>
                          {soul.ooc_notes}
                        </BlockQuote>
                        <br />
                        <LabeledList>
                          <LabeledList.Item label="Outside Hearing">
                            <Button
                              color={soul.outside_hearing ? 'green' : 'red'}
                              fluid
                              tooltip="Is the soul able to hear the outside world?"
                              onClick={() =>
                                act('toggle_soul_outside_sense', {
                                  target_soul: soul.reference,
                                  sense_to_change: 'hearing',
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.outside_hearing ? 'Enabled' : 'Disabled'}
                            </Button>
                          </LabeledList.Item>
                          <LabeledList.Item label="Outside Sight">
                            <Button
                              color={soul.outside_sight ? 'green' : 'red'}
                              fluid
                              tooltip="Is the soul able to see the outside world?"
                              onClick={() =>
                                act('toggle_soul_outside_sense', {
                                  target_soul: soul.reference,
                                  sense_to_change: 'sight',
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.outside_sight ? 'Enabled' : 'Disabled'}
                            </Button>
                          </LabeledList.Item>
                          <LabeledList.Item label="Hearing">
                            <Button
                              color={soul.internal_hearing ? 'green' : 'red'}
                              fluid
                              tooltip="Is the soul able to hear inside the room?"
                              onClick={() =>
                                act('toggle_soul_sense', {
                                  target_soul: soul.reference,
                                  sense_to_change: 'hearing',
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.internal_hearing ? 'Enabled' : 'Disabled'}
                            </Button>
                          </LabeledList.Item>
                          <LabeledList.Item label="Sight">
                            <Button
                              color={soul.internal_sight ? 'green' : 'red'}
                              fluid
                              tooltip="Is the soul able to see inside the room?"
                              onClick={() =>
                                act('toggle_soul_sense', {
                                  target_soul: soul.reference,
                                  sense_to_change: 'sight',
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.internal_sight ? 'Enabled' : 'Disabled'}
                            </Button>
                          </LabeledList.Item>
                          <LabeledList.Item label="Speech">
                            <Button
                              color={soul.able_to_speak ? 'green' : 'red'}
                              fluid
                              tooltip="Is the soul able to speak?"
                              onClick={() =>
                                act('toggle_soul_communication', {
                                  target_soul: soul.reference,
                                  communication_type: 'speech',
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.able_to_speak ? 'Enabled' : 'Disabled'}
                            </Button>
                          </LabeledList.Item>
                          <LabeledList.Item label="Emote">
                            <Button
                              color={soul.able_to_emote ? 'green' : 'red'}
                              fluid
                              tooltip="Is the soul able to emote?"
                              onClick={() =>
                                act('toggle_soul_communication', {
                                  target_soul: soul.reference,
                                  communication_type: 'emote',
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.able_to_emote ? 'Enabled' : 'Disabled'}
                            </Button>
                          </LabeledList.Item>
                          {communicate_as_parent ? (
                            <>
                              <LabeledList.Item label="External Speech">
                                <Button
                                  color={
                                    soul.able_to_speak_as_container
                                      ? 'green'
                                      : 'red'
                                  }
                                  fluid
                                  tooltip="Is the soul able to speak the container?"
                                  onClick={() =>
                                    act('toggle_soul_external_communication', {
                                      target_soul: soul.reference,
                                      communication_type: 'speech',
                                      room_ref: room.reference,
                                    })
                                  }
                                >
                                  {soul.able_to_speak_as_container
                                    ? 'Enabled'
                                    : 'Disabled'}
                                </Button>
                              </LabeledList.Item>
                              <LabeledList.Item label="External Emote">
                                <Button
                                  color={
                                    soul.able_to_emote_as_container
                                      ? 'green'
                                      : 'red'
                                  }
                                  fluid
                                  tooltip="Is the soul able to emote as the container?"
                                  onClick={() =>
                                    act('toggle_soul_external_communication', {
                                      target_soul: soul.reference,
                                      communication_type: 'emote',
                                      room_ref: room.reference,
                                    })
                                  }
                                >
                                  {soul.able_to_emote_as_container
                                    ? 'Enabled'
                                    : 'Disabled'}
                                </Button>
                              </LabeledList.Item>
                            </>
                          ) : (
                            <> </>
                          )}
                          <LabeledList.Item label="Rename">
                            <Button
                              color={soul.able_to_rename ? 'green' : 'red'}
                              fluid
                              tooltip="Is the soul able to rename themselves?"
                              onClick={() =>
                                act('toggle_soul_renaming', {
                                  target_soul: soul.reference,
                                  room_ref: room.reference,
                                })
                              }
                            >
                              {soul.able_to_rename ? 'Enabled' : 'Disabled'}
                            </Button>
                          </LabeledList.Item>
                        </LabeledList>
                        <br />
                        <Button
                          fluid
                          icon="eject"
                          color="red"
                          onClick={() =>
                            act('remove_soul', {
                              target_soul: soul.reference,
                              room_ref: room.reference,
                            })
                          }
                        >
                          Remove Soul
                        </Button>
                      </Collapsible>
                    </Flex.Item>
                  ))}
                </Flex>
              </>
            ) : (
              <> </>
            )}
          </Section>
        ))}
        {max_souls ? (
          <Section>
            <ProgressBar
              textAlign="left"
              minValue={0}
              color="blue"
              maxValue={max_souls}
              value={max_souls - current_soul_count}
            >
              Remaining soul capacity: {max_souls - current_soul_count}
            </ProgressBar>
          </Section>
        ) : (
          <> </>
        )}
        <Button
          fluid
          color="green"
          icon="plus"
          onClick={() => act('create_room', {})}
        >
          Create new room
        </Button>
        <Button
          fluid
          color={ghost_joinable ? 'green' : 'red'}
          icon={ghost_joinable ? 'door-open' : 'door-closed'}
          onClick={() => act('toggle_joinable', {})}
        >
          {ghost_joinable ? 'Opened' : 'Closed'} to ghosts
        </Button>
        <Button
          fluid
          color={require_approval ? 'green' : 'red'}
          icon={require_approval ? 'lock' : 'lock-open'}
          onClick={() => act('toggle_approval', {})}
        >
          Approval is {require_approval ? '' : 'not'} required to join
        </Button>
        {removable ? (
          <Button
            require_approval
            fluid
            color="red"
            icon="eject"
            onClick={() => act('delete_self', {})}
          >
            Remove soulcatcher from parent object
          </Button>
        ) : (
          <> </>
        )}
      </Window.Content>
    </Window>
  );
};
