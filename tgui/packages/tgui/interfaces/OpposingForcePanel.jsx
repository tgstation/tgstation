// THIS IS A NOVA SECTOR UI FILE
import { round } from 'common/math';

import { useBackend, useLocalState } from '../backend';
import { Box, Button, Collapsible, Input, LabeledList, NoticeBox, NumberInput, Section, Slider, Stack, Tabs, TextArea } from '../components';
import { Window } from '../layouts';

export const OpposingForcePanel = (props) => {
  const [tab, setTab] = useLocalState('tab', 1);
  const { act, data } = useBackend();
  const { admin_mode, creator_ckey, owner_antag, opt_in_enabled } = data;
  return (
    <Window
      title={'Opposing Force: ' + creator_ckey}
      width={585}
      height={840}
      theme={owner_antag ? 'syndicate' : 'admin'}>
      <Window.Content scrollable>
        <Stack vertical grow mb={1}>
          <Stack.Item>
            <Tabs fill>
              {admin_mode ? (
                <>
                  <Tabs.Tab
                    width="100%"
                    selected={tab === 1}
                    onClick={() => setTab(1)}>
                    Admin Control
                  </Tabs.Tab>
                  <Tabs.Tab
                    width="100%"
                    selected={tab === 2}
                    onClick={() => setTab(2)}>
                    Admin Chat
                  </Tabs.Tab>
                </>
              ) : (
                <>
                  <Tabs.Tab
                    width="100%"
                    selected={tab === 1}
                    onClick={() => setTab(1)}>
                    Summary
                  </Tabs.Tab>
                  <Tabs.Tab
                    width="100%"
                    selected={tab === 2}
                    onClick={() => setTab(2)}>
                    Equipment
                  </Tabs.Tab>
                  <Tabs.Tab
                    width="100%"
                    selected={tab === 3}
                    onClick={() => setTab(3)}>
                    Admin Chat
                  </Tabs.Tab>
                  {!!opt_in_enabled && (
                    <Tabs.Tab
                      width="100%"
                      selected={tab === 4}
                      onClick={() => setTab(4)}>
                      Target List
                    </Tabs.Tab>
                  )}
                </>
              )}
            </Tabs>
          </Stack.Item>
        </Stack>
        {admin_mode ? (
          <>
            {tab === 1 && <AdminTab />}
            {tab === 2 && <AdminChatTab />}
          </>
        ) : (
          <>
            {tab === 1 && <OpposingForceTab />}
            {tab === 2 && <EquipmentTab />}
            {tab === 3 && <AdminChatTab />}
            {tab === 4 && <TargetTab />}
          </>
        )}
      </Window.Content>
    </Window>
  );
};

export const OpposingForceTab = (props) => {
  const { act, data } = useBackend();
  const {
    creator_ckey,
    objectives = [],
    can_submit,
    status,
    can_request_update,
    request_updates_muted,
    can_edit,
    backstory,
    handling_admin,
    blocked,
    approved,
    denied,
  } = data;
  return (
    <Stack vertical grow>
      <Stack.Item>
        <Section
          title={
            handling_admin
              ? 'Control - Handling Admin: ' + handling_admin
              : 'Control'
          }>
          <Stack>
            <Stack.Item>
              <Button
                icon="check"
                color="good"
                tooltip={
                  'Submit your application for review.' +
                  (blocked ? ' (Blocked)' : '')
                }
                disabled={!can_submit || blocked}
                content="Submit Application"
                onClick={() => act('submit')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="question"
                color="orange"
                tooltip={
                  'Request an update from the admins.' +
                  (request_updates_muted ? ' (Muted)' : '')
                }
                disabled={!can_request_update || request_updates_muted}
                content="Ask For Update"
                onClick={() => act('request_update')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="wrench"
                color="blue"
                tooltip="Modify your application, this will reset all authorisations."
                disabled={can_edit}
                content="Modify Request"
                onClick={() => act('modify_request')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="trash"
                color="bad"
                tooltip="Remove your application from the queue."
                disabled={status === 'Not submitted'}
                content="Withdraw Application"
                onClick={() => act('close_application')}
              />
            </Stack.Item>
          </Stack>
          <Stack>
            <Stack.Item>
              <Button
                icon="file-import"
                color="blue"
                tooltip="Import an application from a .json file."
                disabled={status === 'Awaiting approval'}
                content="Import JSON"
                onClick={() => act('import_json')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="file-export"
                color="purple"
                tooltip="Export an application as a .json file."
                disabled={status === 'Awaiting approval'}
                content="Export JSON"
                onClick={() => act('export_json')}
              />
            </Stack.Item>
          </Stack>
          <Stack>
            <Stack.Item>
              <a href="https://wiki.monkestation.com/en/opfor">
                <Button
                  icon="info"
                  color="orange"
                  tooltip="Open a guide on how to improve your opfors."
                  content="Opfor Guide"
                />
              </a>
            </Stack.Item>
            <Stack.Item>
              <a href="https://wiki.monkestation.com/en/opfor">
                <Button
                  icon="wrench"
                  color="red"
                  tooltip="Open current Opfor standards."
                  content="Opfor Policy"
                />
              </a>
            </Stack.Item>
            <Stack.Item>
              <a href="https://wiki.monkestation.com/en/home">
                <Button
                  icon="question"
                  color="yellow"
                  tooltip="Open policy for Non-Antagonist criminal activity."
                  content="Does this need an Opfor"
                />
              </a>
            </Stack.Item>
          </Stack>
          <NoticeBox
            color={approved ? 'good' : denied ? 'bad' : 'orange'}
            mt={2}>
            {status}
          </NoticeBox>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Backstory">
          <TextArea
            disabled={!can_edit}
            height="100px"
            value={backstory}
            placeholder="Provide a description of why you want to do bad things. Include specifics such as what lead upto the events that made you want to do bad things, think of it as though you were your character, react appropriately. If you don't have any ideas, check the #player-shared-opfors channel for some. (2000 char limit)"
            onChange={(_e, value) =>
              act('set_backstory', {
                backstory: value,
              })
            }
          />
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section
          title="Objectives"
          buttons={
            <Button
              icon="plus"
              content="Add Objective"
              onClick={() => act('add_objective')}
            />
          }>
          {!!objectives.length && <OpposingForceObjectives />}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const OpposingForceObjectives = (props) => {
  const { act, data } = useBackend();
  const { objectives = [], can_edit } = data;

  const [selectedObjectiveID, setSelectedObjective] = useLocalState(
    'objectives',
    objectives[0]?.id
  );

  const selectedObjective = objectives.find((objective) => {
    return objective.id === selectedObjectiveID;
  });

  return (
    <Stack vertical grow>
      {objectives.length > 0 && (
        <Stack.Item>
          <Tabs fill>
            {objectives.map((objective) => (
              <Tabs.Tab
                color={
                  objective.status_text === 'Not Reviewed'
                    ? 'yellow'
                    : objective.approved
                      ? 'good'
                      : 'bad'
                }
                textColor={
                  objective.status_text === 'Not Reviewed'
                    ? 'yellow'
                    : objective.approved
                      ? 'good'
                      : 'bad'
                }
                width="25%"
                key={objective.id}
                selected={objective.id === selectedObjectiveID}
                onClick={() => setSelectedObjective(objective.id)}>
                <Stack align="center">
                  <Stack.Item width="80%">
                    {objective.title ? objective.title : 'Blank Objective'}
                  </Stack.Item>
                  <Stack.Item width="20%">
                    <Button
                      disabled={!can_edit}
                      height="90%"
                      icon="minus"
                      color="bad"
                      textAlign="center"
                      tooltip="Remove objective"
                      onClick={() =>
                        act('remove_objective', {
                          objective_ref: objective.ref,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Tabs.Tab>
            ))}
          </Tabs>
        </Stack.Item>
      )}
      {selectedObjective ? (
        <Stack.Item>
          <Stack vertical>
            <Stack.Item>
              <Stack.Item>
                <Stack vertical>
                  <Stack.Item>Title</Stack.Item>
                  <Stack.Item>
                    <Input
                      disabled={!can_edit}
                      width="100%"
                      placeholder="blank objective"
                      value={selectedObjective.title}
                      onChange={(e, value) =>
                        act('set_objective_title', {
                          objective_ref: selectedObjective.ref,
                          title: value,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack vertical mt={2}>
                  <Stack.Item>
                    Intensity: {selectedObjective.text_intensity}
                  </Stack.Item>
                  <Stack.Item>
                    <Slider
                      disabled={!can_edit}
                      step={0.1}
                      stepPixelSize={0.1}
                      value={selectedObjective.intensity}
                      format={(value) => round(value)}
                      minValue={0}
                      maxValue={500}
                      onDrag={(e, value) =>
                        act('set_objective_intensity', {
                          objective_ref: selectedObjective.ref,
                          new_intensity_level: value,
                        })
                      }
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <Stack>
                      <Stack.Item>
                        <Button
                          ml={7.6}
                          mr={15}
                          disabled={!can_edit}
                          icon="laugh"
                          color="good"
                          onClick={() =>
                            act('set_objective_intensity', {
                              objective_ref: selectedObjective.ref,
                              new_intensity_level: 50,
                            })
                          }
                        />
                        <Button
                          mr={15}
                          disabled={!can_edit}
                          icon="smile"
                          color="teal"
                          onClick={() =>
                            act('set_objective_intensity', {
                              objective_ref: selectedObjective.ref,
                              new_intensity_level: 150,
                            })
                          }
                        />
                        <Button
                          mr={15}
                          disabled={!can_edit}
                          icon="meh-blank"
                          color="olive"
                          onClick={() =>
                            act('set_objective_intensity', {
                              objective_ref: selectedObjective.ref,
                              new_intensity_level: 250,
                            })
                          }
                        />
                        <Button
                          mr={15}
                          disabled={!can_edit}
                          icon="frown"
                          color="orange"
                          onClick={() =>
                            act('set_objective_intensity', {
                              objective_ref: selectedObjective.ref,
                              new_intensity_level: 350,
                            })
                          }
                        />
                        <Button
                          disabled={!can_edit}
                          icon="grimace"
                          color="red"
                          onClick={() =>
                            act('set_objective_intensity', {
                              objective_ref: selectedObjective.ref,
                              new_intensity_level: 450,
                            })
                          }
                        />
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack vertical mt={2}>
                  <Stack.Item>
                    Description
                    <Button
                      icon="info"
                      tooltip="Input objective description here, be descriptive about what you want to do, such as 'Destroy the Death Star' or 'Destroy the Death Star and the Death Star Base' (1000 char limit)."
                      color="light-gray"
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <TextArea
                      fluid
                      disabled={!can_edit}
                      height="85px"
                      value={selectedObjective.description}
                      onChange={(e, value) =>
                        act('set_objective_description', {
                          objective_ref: selectedObjective.ref,
                          new_desciprtion: value,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item>
                <Stack vertical mt={2}>
                  <Stack.Item>
                    Justification
                    <Button
                      icon="info"
                      tooltip="Input justification for the objective here, make sure you have a good reason for the objective (1000 char limit)."
                      color="light-gray"
                    />
                  </Stack.Item>
                  <Stack.Item>
                    <TextArea
                      disabled={!can_edit}
                      height="85px"
                      value={selectedObjective.justification}
                      onChange={(e, value) =>
                        act('set_objective_justification', {
                          objective_ref: selectedObjective.ref,
                          new_justification: value,
                        })
                      }
                    />
                  </Stack.Item>
                </Stack>
              </Stack.Item>
              <Stack.Item mt={2}>
                <NoticeBox color={selectedObjective.approved ? 'good' : 'bad'}>
                  {selectedObjective.status_text === 'Not Reviewed'
                    ? 'Objective Not Reviewed'
                    : selectedObjective.approved
                      ? 'Objective Approved'
                      : selectedObjective.denied_text
                        ? 'Objective Denied - Reason: ' +
                        selectedObjective.denied_text
                        : 'Objective Denied'}
                </NoticeBox>
              </Stack.Item>
            </Stack.Item>
          </Stack>
        </Stack.Item>
      ) : (
        <Stack.Item>No objectives selected.</Stack.Item>
      )}
    </Stack>
  );
};

export const EquipmentTab = (props) => {
  const { act, data } = useBackend();
  const { equipment_list = [], selected_equipment = [], can_edit } = data;
  return (
    <Stack vertical grow>
      <Stack.Item>
        <Section title="Selected Equipment">
          {selected_equipment.length === 0 ? (
            <Box color="bad">No equipment selected.</Box>
          ) : (
            selected_equipment.map((equipment) => (
              <>
                <LabeledList key={equipment.ref}>
                  <LabeledList.Item
                    buttons={
                      <>
                        <NumberInput
                          animated
                          value={equipment.count}
                          minValue={1}
                          maxValue={5}
                          onChange={(e, value) =>
                            act('set_equipment_count', {
                              selected_equipment_ref: equipment.ref,
                              new_equipment_count: value,
                            })
                          }
                        />
                        <Button
                          icon="times"
                          color="bad"
                          content="Remove"
                          onClick={() =>
                            act('remove_equipment', {
                              selected_equipment_ref: equipment.ref,
                            })
                          }
                        />
                      </>
                    }
                    label={equipment.name}
                  />
                  <LabeledList.Item label="Status">
                    {equipment.denied_reason
                      ? equipment.status +
                      ' - Reason: ' +
                      equipment.denied_reason
                      : equipment.status}
                  </LabeledList.Item>
                </LabeledList>
                <Input
                  mt={1}
                  mb={1}
                  disabled={!can_edit}
                  width="100%"
                  placeholder="Reason for item"
                  value={equipment.reason}
                  onChange={(e, value) =>
                    act('set_equipment_reason', {
                      selected_equipment_ref: equipment.ref,
                      new_equipment_reason: value,
                    })
                  }
                />
              </>
            ))
          )}
        </Section>
        <Section title="Available Equipment">
          <Stack vertical fill>
            {equipment_list.map((equipment_category) => (
              <Stack.Item key={equipment_category.category}>
                <Collapsible
                  title={equipment_category.category}
                  key={equipment_category.category}>
                  <Section>
                    {equipment_category.items.map((item) => (
                      <Section
                        title={item.name}
                        key={item.ref}
                        buttons={
                          <Button
                            icon="check"
                            color="good"
                            content="Select"
                            disabled={!can_edit}
                            onClick={() =>
                              act('select_equipment', {
                                equipment_ref: item.ref,
                              })
                            }
                          />
                        }>
                        <LabeledList>
                          <LabeledList.Item label="Description">
                            {item.description}
                          </LabeledList.Item>
                        </LabeledList>
                      </Section>
                    ))}
                  </Section>
                </Collapsible>
              </Stack.Item>
            ))}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const AdminChatTab = (props) => {
  const { act, data } = useBackend();
  const { messages = [] } = data;
  return (
    <Stack vertical fill>
      <Stack.Item grow={10}>
        <Section scrollable fill>
          {messages.map((message) => (
            <Box key={message.msg}>{message.msg}</Box>
          ))}
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Input
          height="22px"
          fluid
          selfClear
          placeholder="Send a message or command using '/'"
          mt={1}
          onEnter={(e, value) =>
            act('send_message', {
              message: value,
            })
          }
        />
      </Stack.Item>
    </Stack>
  );
};

export const AdminTab = (props) => {
  const { act, data } = useBackend();
  const {
    request_updates_muted,
    approved,
    denied,
    objectives = [],
    selected_equipment = [],
    backstory,
    blocked,
    equipment_issued,
    owner_mob,
    owner_role,
    raw_status,
  } = data;
  return (
    <Stack vertical grow>
      <Stack.Item>
        <Section title="User Information">
          <LabeledList>
            <LabeledList.Item label="Name">{owner_mob}</LabeledList.Item>
            <LabeledList.Item label="Role">{owner_role}</LabeledList.Item>
            <LabeledList.Item label="Application Status">
              {raw_status}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Admin Control">
          <Stack mb={1}>
            <Stack.Item>
              <Button
                icon="check"
                color="good"
                tooltip="Approve the application, and any approved objectives."
                disabled={approved}
                content="Approve"
                onClick={() => act('approve')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="check-double"
                color="orange"
                tooltip="Approve all objectives and equipment as well as the application. Make sure you have reviewed the application and objectives first!"
                disabled={approved}
                content="Approve All"
                onClick={() => act('approve_all')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="universal-access"
                color="purple"
                disabled={!approved || equipment_issued}
                tooltip="Issue the player with all approved equipment."
                content="Issue Gear"
                onClick={() => act('issue_gear')}
              />
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="times"
                color="red"
                disabled={denied}
                content="Deny"
                onClick={() => act('deny')}
              />
            </Stack.Item>
            <Stack.Item>
              {blocked ? (
                <Button
                  icon="check-circle"
                  color="green"
                  tooltip="Unblock the user from submitting applications."
                  content="Unblock User"
                  onClick={() => act('toggle_block')}
                />
              ) : (
                <Button
                  icon="ban"
                  color="red"
                  tooltip="Block the user from submitting applications."
                  content="Block User"
                  onClick={() => act('toggle_block')}
                />
              )}
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="suitcase"
                color="blue"
                tooltip="Assign yourself as the handling admin."
                content="Handle"
                onClick={() => act('handle')}
              />
            </Stack.Item>
          </Stack>
          <Stack>
            <Stack.Item>
              {request_updates_muted ? (
                <Button
                  icon="volume-up"
                  color="green"
                  content="Unmute Help Requests"
                  onClick={() => act('mute_request_updates')}
                />
              ) : (
                <Button
                  icon="volume-mute"
                  color="red"
                  content="Mute Help Requests"
                  onClick={() => act('mute_request_updates')}
                />
              )}
            </Stack.Item>
            <Stack.Item>
              <Button
                icon="compress-arrows-alt"
                color="teal"
                tooltip="Follow User Mob"
                content="Follow"
                onClick={() => act('flw_user')}
              />
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Backstory">
          {backstory.length === 0 ? (
            <Box color="bad">No backstory set.</Box>
          ) : (
            <Box preserveWhitespace>{backstory}</Box>
          )}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Objectives">
          {objectives.length === 0 ? (
            <Box color="bad">No objectives selected.</Box>
          ) : (
            objectives.map((objective, index) => (
              <Section
                title={index + 1 + '. ' + objective.title}
                key={objective.id}>
                <Stack vertical>
                  <Stack.Item>
                    <LabeledList key={objective.id}>
                      <LabeledList.Item label="Description">
                        {objective.description}
                      </LabeledList.Item>
                      <LabeledList.Item label="Justification">
                        {objective.justification}
                      </LabeledList.Item>
                      <LabeledList.Item label="Intensity">
                        {'(' +
                          objective.intensity +
                          ') ' +
                          objective.text_intensity}
                      </LabeledList.Item>
                      <LabeledList.Item label="Status">
                        {objective.status_text === 'Not Reviewed'
                          ? 'Objective Not Reviewed'
                          : objective.approved
                            ? 'Objective Approved'
                            : objective.denied_text
                              ? 'Objective Denied - Reason: ' +
                              objective.denied_text
                              : 'Objective Denied'}
                      </LabeledList.Item>
                    </LabeledList>
                  </Stack.Item>
                  <Stack mb={-1.5}>
                    <Stack.Divider hidden grow width="50%" />
                    <Stack.Item>
                      <Button
                        icon="check"
                        color="good"
                        disabled={
                          objective.approved &&
                          objective.status_text !== 'Not Reviewed'
                        }
                        content="Approve Objective"
                        onClick={() =>
                          act('approve_objective', {
                            objective_ref: objective.ref,
                          })
                        }
                      />
                    </Stack.Item>
                    <Stack.Item>
                      <Button
                        icon="times"
                        color="bad"
                        disabled={
                          !objective.approved &&
                          objective.status_text !== 'Not Reviewed'
                        }
                        content="Deny Objective"
                        onClick={() =>
                          act('deny_objective', {
                            objective_ref: objective.ref,
                          })
                        }
                      />
                    </Stack.Item>
                  </Stack>
                </Stack>
              </Section>
            ))
          )}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section title="Equipment">
          {selected_equipment.length === 0 ? (
            <Box color="bad">No equipment selected.</Box>
          ) : (
            selected_equipment.map((equipment, index) => (
              <Section
                title={equipment.name}
                key={equipment.ref}
                buttons={
                  <>
                    <Button
                      icon="check"
                      color="good"
                      disabled={
                        equipment.approved &&
                        equipment.status !== 'Not Reviewed'
                      }
                      content="Approve Equipment"
                      onClick={() =>
                        act('approve_equipment', {
                          selected_equipment_ref: equipment.ref,
                        })
                      }
                    />
                    <Button
                      icon="times"
                      color="bad"
                      disabled={
                        !equipment.approved &&
                        equipment.status !== 'Not Reviewed'
                      }
                      content="Deny Equipment"
                      onClick={() =>
                        act('deny_equipment', {
                          selected_equipment_ref: equipment.ref,
                        })
                      }
                    />
                  </>
                }>
                <LabeledList key={equipment.ref}>
                  <LabeledList.Item label="Description">
                    {equipment.description}
                  </LabeledList.Item>
                  <LabeledList.Item label="Reason">
                    {equipment.reason}
                  </LabeledList.Item>
                  <LabeledList.Item label="Status">
                    {equipment.denied_reason
                      ? equipment.status +
                      ' - Reason: ' +
                      equipment.denied_reason
                      : equipment.status}
                  </LabeledList.Item>
                  <LabeledList.Item label="Amount">
                    {equipment.count}
                  </LabeledList.Item>
                  <LabeledList.Item label="Equipment Note">
                    {equipment.admin_note}
                  </LabeledList.Item>
                </LabeledList>
              </Section>
            ))
          )}
        </Section>
      </Stack.Item>
    </Stack>
  );
};

export const TargetTab = (props) => {
  const { act, data } = useBackend();
  const { current_crew = [], opt_in_colors = { optin, color } } = data;
  return (
    <Stack vertical fill>
      <Stack.Item grow={10}>
        <Section title="Currently active crew">
          {current_crew.map((crew) => (
            <Stack vertical={false} key={crew.name} pb="10px">
              <Stack.Item>
                <span style={{ textDecoration: 'underline' }}>{crew.name}</span>
                {': '}
                {crew.rank}, Current Opt-In status:{' '}
                <span
                  style={{
                    fontWeight: 'bold',
                    color: opt_in_colors[crew.opt_in_status],
                  }}>
                  {crew.opt_in_status}
                </span>
                , Ideal Opt-in status:{' '}
                <span
                  style={{ color: opt_in_colors[crew.ideal_opt_in_status] }}>
                  {crew.ideal_opt_in_status}
                </span>
              </Stack.Item>
            </Stack>
          ))}
        </Section>
      </Stack.Item>
    </Stack>
  );
};
