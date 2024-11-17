import { useState } from 'react';

import { useBackend } from '../backend';
import {
  BlockQuote,
  Button,
  DmIcon,
  LabeledList,
  Section,
  Stack,
  Table,
  Tabs,
} from '../components';
import { Window } from '../layouts';

const tipstyle = {
  color: 'white',
};

const noticestyle = {
  color: 'lightblue',
};

type UpgradesInfo = {
  upgrades_charges: number;
  upgrades_list: UpgradesBox[];
};

type UpgradesBox = {
  branches_tier_1: UpgradeBranch[];
  branches_tier_2: UpgradeBranch[];
  branches_tier_3: UpgradeBranch[];
  name: string;
  desc: string;
  icon: string;
  icon_state: string;
  is_unlocked: boolean;
};

type UpgradeBranch = {
  name: string;
  desc: string;
  type: string;
  discaunt: boolean;
  available: boolean;
};

const VoidwalkerIntroduction = (props) => {
  return (
    <Stack fill>
      <Stack.Item width="46.2%">
        <Section fill>
          <Stack vertical fill>
            <Stack.Item fontSize="25px">You are a Voidwalker.</Stack.Item>
            <Stack.Item>
              <BlockQuote>
                You are a creature from the void between stars. You were
                attracted to the radio signals being broadcasted by this
                station.
              </BlockQuote>
            </Stack.Item>
            <Stack.Divider />
            <Stack.Item textColor="label">
              <span style={tipstyle}>Survive:&ensp;</span>
              You have unrivaled freedom. Remain in space and no one can stop
              you. You can move through windows, so stay near them to always
              have a way out.
              <br />
              <span style={tipstyle}>Hunt:&ensp;</span>
              Pick unfair fights. Look for inattentive targets and strike at
              them when they don&apos;t expect you.
              <br />
              <span style={tipstyle}>Abduct:&ensp;</span>
              Your Unsettle ability stuns and drains your targets. Finish them
              with your void window and use it to pop a window, drag them into
              space and use an empty hand to kidnap them.
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Item width="53%">
        <Section fill title="Powers">
          <LabeledList>
            <LabeledList.Item label="Space Dive">
              You can move under the station from space, use this to hunt and
              get to isolated sections of space.
            </LabeledList.Item>
            <LabeledList.Item label="Void Eater">
              Your divine appendage; it allows you to incapacitate the loud ones
              and instantly break windows.
            </LabeledList.Item>
            <LabeledList.Item label="Cosmic Physiology">
              Your natural camouflage makes you nearly invisible in space, as
              well as mending any wounds your body might have sustained. You can
              move through glass freely, but are slowed in gravity.
            </LabeledList.Item>
            <LabeledList.Item label="Unsettle">
              Target a victim while remaining only partially in their view to
              stun and weaken them, but also announce them your presence.
            </LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const VoidwalkerUpgrades = (props) => {
  const { act, data } = useBackend<UpgradesInfo>();
  const { upgrades_list, upgrades_charges } = data;

  return (
    <Section fill scrollable>
      <Stack.Item fontSize="20px" textAlign="center">
        {upgrades_charges} Upgrade points left to spend.
      </Stack.Item>
      {upgrades_list.length > 0 && (
        <Stack.Item>
          {upgrades_list.map((upgrade_box) => (
            <Section fill title={upgrade_box.name} key={upgrade_box.name}>
              <Table.Row>
                <Table.Cell verticalAlign="middle">
                  <DmIcon
                    icon={upgrade_box.icon}
                    icon_state={upgrade_box.icon_state}
                    height={'80px'}
                    width={'80px'}
                  />
                </Table.Cell>
                <Table.Cell verticalAlign="middle" height="120px" width="240px">
                  {upgrade_box.desc}
                </Table.Cell>
                {upgrade_box.is_unlocked ? (
                  <Stack.Item grow>
                    <Table.Cell>
                      {upgrade_box.branches_tier_1.map((upgrade) => (
                        <Stack.Item key={upgrade.name}>
                          <Button
                            lineHeight={2}
                            my={1}
                            mx={1}
                            fluid
                            tooltip={upgrade.desc}
                            content={upgrade.name}
                            icon={upgrade.discaunt ? 'brain' : ''}
                            color={upgrade.available ? 'purple' : 'black'}
                            onClick={() => {
                              upgrade.available &&
                                act('research', {
                                  what_upgrade: upgrade.type,
                                });
                            }}
                          />
                        </Stack.Item>
                      ))}
                    </Table.Cell>
                    <Table.Cell>
                      {upgrade_box.branches_tier_2.map((upgrade) => (
                        <Stack.Item key={upgrade.name}>
                          <Button
                            lineHeight={2}
                            my={1}
                            mx={1}
                            fluid
                            tooltip={upgrade.desc}
                            content={upgrade.name}
                            icon={upgrade.discaunt ? 'brain' : ''}
                            color={upgrade.available ? 'purple' : 'black'}
                            onClick={() => {
                              upgrade.available &&
                                act('research', {
                                  what_upgrade: upgrade.type,
                                });
                            }}
                          />
                        </Stack.Item>
                      ))}
                    </Table.Cell>
                    <Table.Cell>
                      {upgrade_box.branches_tier_3.map((upgrade) => (
                        <Stack.Item key={upgrade.name}>
                          <Button
                            lineHeight={2}
                            my={1}
                            mx={1}
                            fluid
                            tooltip={upgrade.desc}
                            content={upgrade.name}
                            icon={upgrade.discaunt ? 'brain' : ''}
                            color={upgrade.available ? 'purple' : 'black'}
                            onClick={() => {
                              upgrade.available &&
                                act('research', {
                                  what_upgrade: upgrade.type,
                                });
                            }}
                          />
                        </Stack.Item>
                      ))}
                    </Table.Cell>
                  </Stack.Item>
                ) : (
                  <Button
                    content="Unlock"
                    icon="lock"
                    width={16}
                    height={6}
                    textAlign="center"
                    tooltip="You need 2 points to unlock this spell."
                    py={4}
                    my={6}
                    mx={4}
                    color="purple"
                    onClick={() => {
                      act('unlock', {
                        what_unlock: upgrade_box.name,
                      });
                    }}
                  />
                )}
              </Table.Row>
            </Section>
          ))}
        </Stack.Item>
      )}
    </Section>
  );
};

export const AntagInfoVoidwalker = (props) => {
  const [currentTab, setTab] = useState(0);

  return (
    <Window width={875} height={635}>
      <Window.Content backgroundColor="#0d0d0d">
        <Stack vertical fill>
          <Stack.Item>
            <Tabs fluid>
              <Tabs.Tab
                icon="info"
                selected={currentTab === 0}
                onClick={() => setTab(0)}
              >
                Information
              </Tabs.Tab>
              <Tabs.Tab
                icon={'brain'}
                selected={currentTab === 1}
                onClick={() => setTab(1)}
              >
                Growth
              </Tabs.Tab>
            </Tabs>
          </Stack.Item>
          <Stack.Item grow>
            {(currentTab === 0 && <VoidwalkerIntroduction />) || (
              <VoidwalkerUpgrades />
            )}
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};
