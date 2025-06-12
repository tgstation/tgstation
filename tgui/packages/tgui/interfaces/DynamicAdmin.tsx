import { useState } from 'react';
import {
  BlockQuote,
  Box,
  Button,
  Dropdown,
  Flex,
  Input,
  LabeledList,
  NoticeBox,
  Section,
  Stack,
  Tabs,
  Tooltip,
} from 'tgui-core/components';
import { BooleanLike } from 'tgui-core/react';
import { createSearch } from 'tgui-core/string';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type RulesetCount = Record<string, number>;

type DynamicConfig = Record<string, any>;

type typePath = string;

type Player = {
  key: string;
};

type RulesetReport = RulesetType & {
  index: number;
  selected_players: Player[];
  hidden: BooleanLike;
};

type RulesetType = {
  name: string;
  id: string;
  typepath: typePath;
  admin_disabled: BooleanLike;
};

type Data = {
  current_tier?: {
    number: number;
    name: string;
  };
  ruleset_count?: RulesetCount;
  full_config?: DynamicConfig;
  queued_rulesets: RulesetReport[];
  active_rulesets: RulesetReport[];
  all_rulesets: Record<string, RulesetType[]>;
  time_until_lights: number;
  time_until_heavies: number;
  time_until_latejoins: number;
  time_until_next_midround: number;
  time_until_next_latejoin: number;
  failed_latejoins: number;
  light_midround_chance: number;
  heavy_midround_chance: number;
  latejoin_chance: number;
  roundstarted: BooleanLike;
  config_even_enabled: BooleanLike;
  light_chance_maxxed: BooleanLike;
  heavy_chance_maxxed: BooleanLike;
  latejoin_chance_maxxed: BooleanLike;
  next_dynamic_tick: number;
  antag_events_enabled: BooleanLike;
};

function formatTime(seconds: number): string {
  seconds /= 10;
  if (seconds < 0) {
    return 'never';
  }
  const hours = Math.floor(seconds / 3600);
  const minutes = Math.floor((seconds % 3600) / 60);
  const secs = Math.round(seconds % 60);

  return `${hours}h ${minutes}m ${secs}s`;
}

function getPlayerString(players: Player[]): string {
  if (players.length === 0) {
    return 'No one';
  } else if (players.length === 1) {
    return players[0].key;
  } else if (players.length === 2) {
    return `${players[0].key} and ${players[1].key}`;
  }
  let playerString = '';
  for (let i = 0; i < players.length; i++) {
    playerString += players[i].key;
    if (i < players.length - 1) {
      playerString += ', ';
    }
    if (i === players.length - 2) {
      playerString += 'and ';
    }
  }
  return playerString;
}

function readableRulesesetCategory(ruleset_category: string): string {
  // Replace underlines with spaces and auto-capitalize first letter of every word
  return ruleset_category
    .replace(/_/g, ' ')
    .split(' ')
    .map((word) => word.charAt(0).toUpperCase() + word.slice(1))
    .join(' ');
}

const StatusPanel = () => {
  const { data, act } = useBackend<Data>();
  const {
    current_tier,
    ruleset_count,
    time_until_lights,
    time_until_heavies,
    time_until_latejoins,
    time_until_next_midround,
    time_until_next_latejoin,
    failed_latejoins,
    light_midround_chance,
    heavy_midround_chance,
    latejoin_chance,
    roundstarted,
    light_chance_maxxed,
    heavy_chance_maxxed,
    latejoin_chance_maxxed,
    next_dynamic_tick,
  } = data;

  if (!current_tier) {
    return (
      <LabeledList>
        <LabeledList.Item label="Current Tier">
          <Button onClick={() => act('set_tier')}>(Click to set)</Button>
        </LabeledList.Item>
      </LabeledList>
    );
  }

  return (
    <LabeledList>
      <LabeledList.Item label="Current Tier">
        <Box>
          <b>{current_tier.number}</b> ({current_tier.name})
        </Box>
        {!roundstarted && (
          <Button ml={1} onClick={() => act('set_tier')}>
            (Change)
          </Button>
        )}
      </LabeledList.Item>
      {ruleset_count &&
        Object.entries(ruleset_count).map(([name, count]) => (
          <LabeledList.Item
            key={name}
            label={`${readableRulesesetCategory(name)} Ruleset Count`}
          >
            <Flex>
              <Flex.Item>{count}</Flex.Item>
              {(name !== 'roundstart' || !roundstarted) && (
                <Flex.Item ml={1}>
                  <Button
                    icon="plus"
                    tooltip="Add one max ruleset of this type"
                    tooltipPosition="right"
                    onClick={() =>
                      act('add_ruleset_category_count', {
                        ruleset_category: name,
                      })
                    }
                  />
                </Flex.Item>
              )}
              {(name !== 'roundstart' || !roundstarted) && (
                <Flex.Item ml={0.5}>
                  <Button
                    icon="times"
                    disabled={count === 0}
                    tooltip="Set max ruleset of this type to 0"
                    tooltipPosition="right"
                    onClick={() =>
                      act('set_ruleset_category_count', {
                        ruleset_category: name,
                        ruleset_count: 0,
                      })
                    }
                  />
                </Flex.Item>
              )}
            </Flex>
          </LabeledList.Item>
        ))}
      {time_until_lights > 0 ? (
        <LabeledList.Item label="Light Midround Start">
          <Flex>
            <Flex.Item>
              <Box>{formatTime(time_until_lights)}</Box>
            </Flex.Item>
            <Flex.Item>
              <Button ml={1} onClick={() => act('light_start_now')}>
                Start Now
              </Button>
            </Flex.Item>
          </Flex>
        </LabeledList.Item>
      ) : (
        <>
          <LabeledList.Item label="Light Midround Cooldown">
            <Flex>
              <Flex.Item>
                <Box>
                  {time_until_next_midround > 0
                    ? formatTime(time_until_next_midround)
                    : `Next dynamic tick (${formatTime(next_dynamic_tick)})`}
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button
                  ml={1}
                  disabled={time_until_next_midround <= 0}
                  onClick={() => act('reset_midround_cooldown')}
                >
                  Reset Cooldown
                </Button>
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
          <LabeledList.Item label="Light Midround Chance">
            <Flex>
              <Flex.Item>
                <Box
                  inline
                  style={{
                    borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
                  }}
                >
                  <Tooltip content="Chance of a light midround ruleset being selected on next dynamic tick">
                    {light_midround_chance}%
                  </Tooltip>
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button ml={1} onClick={() => act('max_light_chance')}>
                  {light_chance_maxxed ? 'Reset' : 'Set to 100%'}
                </Button>
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
        </>
      )}
      {time_until_heavies > 0 ? (
        <LabeledList.Item label="Heavy Midround Start">
          <Flex>
            <Flex.Item>
              <Box>{formatTime(time_until_heavies)}</Box>
            </Flex.Item>
            <Flex.Item>
              <Button ml={1} onClick={() => act('heavy_start_now')}>
                Start Now
              </Button>
            </Flex.Item>
          </Flex>
        </LabeledList.Item>
      ) : (
        <>
          <LabeledList.Item label="Heavy Midround Cooldown">
            <Flex>
              <Flex.Item>
                <Box>
                  {time_until_next_midround > 0
                    ? formatTime(time_until_next_midround)
                    : `Next dynamic tick (${formatTime(next_dynamic_tick)})`}
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button
                  ml={1}
                  disabled={time_until_next_midround <= 0}
                  onClick={() => act('reset_midround_cooldown')}
                >
                  Reset Cooldown
                </Button>
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
          <LabeledList.Item label="Heavy Midround Chance">
            <Flex>
              <Flex.Item>
                <Box
                  inline
                  style={{
                    borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
                  }}
                >
                  <Tooltip content="Chance of a heavy midround ruleset being selected on next dynamic tick">
                    {heavy_midround_chance}%
                  </Tooltip>
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button ml={1} onClick={() => act('max_heavy_chance')}>
                  {heavy_chance_maxxed ? 'Reset' : 'Set to 100%'}
                </Button>
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
        </>
      )}
      {time_until_latejoins > 0 ? (
        <LabeledList.Item label="Latejoin Start">
          <Flex>
            <Flex.Item>
              <Box>{formatTime(time_until_latejoins)}</Box>
            </Flex.Item>
            <Flex.Item>
              <Button ml={1} onClick={() => act('latejoin_start_now')}>
                Start Now
              </Button>
            </Flex.Item>
          </Flex>
        </LabeledList.Item>
      ) : (
        <>
          <LabeledList.Item label="Latejoin Cooldown">
            <Flex>
              <Flex.Item>
                <Box>
                  {time_until_next_latejoin
                    ? formatTime(time_until_next_latejoin)
                    : 'Next latejoin'}
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button
                  ml={1}
                  disabled={time_until_next_latejoin <= 0}
                  onClick={() => act('reset_latejoin_cooldown')}
                >
                  Reset Cooldown
                </Button>
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
          <LabeledList.Item label="Latejoin Chance">
            <Flex>
              <Flex.Item>
                <Box
                  inline
                  style={{
                    borderBottom: '2px dotted rgba(255, 255, 255, 0.8)',
                  }}
                >
                  <Tooltip
                    content="Chance the next person who joins the game will selected for a latejoin ruleset.
              Note this does not GUARANTEE a latejoin ruleset is ran - if it fails,
              the chance will increase for the next player who joins."
                  >
                    {latejoin_chance}% ({failed_latejoins} failed attempts)
                  </Tooltip>
                </Box>
              </Flex.Item>
              <Flex.Item>
                <Button ml={1} onClick={() => act('max_latejoin_chance')}>
                  {latejoin_chance_maxxed ? 'Reset' : 'Set to 100%'}
                </Button>
              </Flex.Item>
            </Flex>
          </LabeledList.Item>
        </>
      )}
    </LabeledList>
  );
};

// This just reports the entire config
const ConfigPanel = () => {
  const { data, act } = useBackend<Data>();
  const { full_config } = data;
  // Config given to us is basically just a big json object
  // Future TODO make this a whole functional config editor

  if (!full_config) {
    return (
      <NoticeBox>
        No config loaded - refer to repo defaults for reference.
      </NoticeBox>
    );
  }

  const configKeys = Object.keys(full_config);
  const [shownConfig, setShownConfig] = useState(configKeys[0]);

  return (
    <Stack vertical fill>
      <Stack.Item>
        <NoticeBox>
          This is the current config read by the dynamic system when running
          rulesets. If you want to edit these values temporarily, you can do so
          via View Variables. (Note: Editing tier configs has no effect after
          roundstart)
        </NoticeBox>
      </Stack.Item>
      <Stack.Item>
        <Dropdown
          options={configKeys}
          selected={shownConfig}
          onSelected={(key) => setShownConfig(key)}
        />
      </Stack.Item>
      <Stack.Item height="180px">
        <Section fill scrollable>
          <LabeledList>
            {Object.entries(full_config[shownConfig]).map(
              ([config_name, config]) => (
                <LabeledList.Item key={config_name} label={config_name}>
                  <Box
                    style={{
                      wordBreak: 'break-all',
                      wordWrap: 'break-word',
                    }}
                  >
                    {JSON.stringify(config)}
                  </Box>
                </LabeledList.Item>
              ),
            )}
          </LabeledList>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

// This is where you can see queued rulesets, active rulesets, and trigger new ones
const RulesetsPanel = () => {
  const { data, act } = useBackend<Data>();
  const { all_rulesets, queued_rulesets, active_rulesets, roundstarted } = data;

  const any_admin_disabled = Object.values(all_rulesets).some((ruleset_list) =>
    ruleset_list.some((ruleset) => ruleset.admin_disabled),
  );
  const all_admin_disabled = Object.values(all_rulesets).every((ruleset_list) =>
    ruleset_list.every((ruleset) => ruleset.admin_disabled),
  );

  const [searchText, setSearchText] = useState('');
  const searchFilter = createSearch(
    searchText,
    (ruleset: RulesetType) => ruleset.name,
  );

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title="Queued Rulesets">
          <Stack vertical>
            {queued_rulesets.length === 0 ? (
              <Stack.Item grow>
                <NoticeBox align="center">No rulesets queued.</NoticeBox>
              </Stack.Item>
            ) : (
              queued_rulesets.map((ruleset) => (
                <Stack.Item key={ruleset.id}>
                  <Button
                    mr={0.5}
                    icon="times"
                    tooltip="Remove from queue"
                    onClick={() =>
                      act('remove_queued_ruleset', {
                        ruleset_index: ruleset.index,
                      })
                    }
                  />
                  {ruleset.name} ({ruleset.id})
                </Stack.Item>
              ))
            )}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item>
        <Section title="Active Rulesets">
          <Stack vertical>
            {active_rulesets.length === 0 ? (
              <Stack.Item grow>
                <NoticeBox align="center">No rulesets active.</NoticeBox>
              </Stack.Item>
            ) : (
              active_rulesets.map((ruleset) => (
                <Stack.Item key={ruleset.id}>
                  <Flex>
                    <Flex.Item
                      style={
                        ruleset.hidden
                          ? { textDecoration: 'line-through' }
                          : undefined
                      }
                    >
                      {ruleset.name} ({ruleset.id})
                    </Flex.Item>
                    <Flex.Item ml={1}>
                      <Button.Checkbox
                        checked={ruleset.hidden}
                        icon="times"
                        tooltip="If checked, this ruleset
                          will not show in the roundend report."
                        onClick={() =>
                          act('hide_ruleset', {
                            ruleset_index: ruleset.index,
                          })
                        }
                      />
                    </Flex.Item>
                  </Flex>
                  <BlockQuote>
                    Selected: {getPlayerString(ruleset.selected_players)}
                  </BlockQuote>
                </Stack.Item>
              ))
            )}
          </Stack>
        </Section>
      </Stack.Item>
      <Stack.Divider />
      <Stack.Item height="330px">
        <Section
          fill
          title="Available Rulesets"
          scrollable
          buttons={
            <>
              <Input
                placeholder="Search for ruleset..."
                onChange={setSearchText}
                expensive
                value={searchText}
              />
              <Button
                disabled={all_admin_disabled}
                onClick={() => act('disable_all')}
              >
                Disable All
              </Button>
              <Button
                disabled={!any_admin_disabled}
                onClick={() => act('enable_all')}
              >
                Enable All
              </Button>
            </>
          }
        >
          <Stack>
            {Object.entries(all_rulesets).map(
              ([ruleset_category, ruleset_list]) => (
                <Stack.Item key={ruleset_category} grow>
                  <Stack vertical>
                    <Stack.Item align="center">
                      <h4>{readableRulesesetCategory(ruleset_category)}</h4>
                    </Stack.Item>
                    {ruleset_list
                      .filter(searchFilter)
                      .sort((a, b) => (a.name > b.name ? 1 : -1))
                      .map((ruleset, index) => (
                        <Stack.Item key={ruleset.id}>
                          <Flex>
                            {ruleset_category === 'roundstart' ||
                            ruleset_category === 'latejoin' ? (
                              <Flex.Item>
                                <Button
                                  icon="plus"
                                  tooltip={
                                    ruleset_category === 'roundstart' &&
                                    roundstarted
                                      ? 'Round already started!'
                                      : 'Add to queue'
                                  }
                                  tooltipPosition="right"
                                  disabled={
                                    ruleset_category === 'roundstart' &&
                                    roundstarted
                                  }
                                  onClick={() =>
                                    act('add_queued_ruleset', {
                                      ruleset_type: ruleset.typepath,
                                    })
                                  }
                                />
                              </Flex.Item>
                            ) : (
                              <Flex.Item>
                                <Button
                                  icon="play"
                                  tooltip="Execute this ruleset"
                                  tooltipPosition="right"
                                  onClick={() =>
                                    act('execute_ruleset', {
                                      ruleset_type: ruleset.typepath,
                                    })
                                  }
                                />
                              </Flex.Item>
                            )}
                            {(ruleset_category !== 'roundstart' ||
                              !roundstarted) && (
                              <Flex.Item>
                                <Button.Checkbox
                                  ml={0.5}
                                  tooltipPosition="right"
                                  tooltip="If checked, this ruleset
                                      will never run randomly."
                                  checked={ruleset.admin_disabled}
                                  color={
                                    ruleset.admin_disabled ? 'bad' : 'grey'
                                  }
                                  disabled={
                                    ruleset_category === 'roundstart' &&
                                    roundstarted
                                  }
                                  onClick={() =>
                                    act('disable_ruleset', {
                                      ruleset_type: ruleset.typepath,
                                    })
                                  }
                                />
                              </Flex.Item>
                            )}
                            <Flex.Item
                              style={{
                                borderBottom:
                                  '2px dotted rgba(255, 255, 255, 0.8)',
                              }}
                              ml={1}
                            >
                              <Tooltip content={`ID: ${ruleset.id}`}>
                                {ruleset.name}
                              </Tooltip>
                            </Flex.Item>
                          </Flex>
                        </Stack.Item>
                      ))}
                  </Stack>
                </Stack.Item>
              ),
            )}
          </Stack>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

enum TABS {
  Status = 'Status',
  Rulesets = 'Rulesets',
  Config = 'Config',
}

export const DynamicAdmin = () => {
  const { act, data } = useBackend<Data>();
  const { config_even_enabled, antag_events_enabled } = data;

  // disable config tab if config_even_enabled is false
  const tabs_filtered = Object.keys(TABS).filter(
    (tab) => tab !== TABS.Config || config_even_enabled,
  );

  const [currentTab, setCurrentTab] = useState(tabs_filtered[0]);

  let componentShown;

  switch (currentTab) {
    case TABS.Status:
      componentShown = <StatusPanel />;
      break;
    case TABS.Config:
      componentShown = <ConfigPanel />;
      break;
    case TABS.Rulesets:
      componentShown = <RulesetsPanel />;
      break;
    default:
      componentShown = <StatusPanel />;
  }

  return (
    <Window
      title="Dynamic Admin Panel"
      width={currentTab === TABS.Rulesets ? 800 : 500}
      height={currentTab === TABS.Rulesets ? 600 : 400}
    >
      <Window.Content>
        <Section
          title="&nbsp;"
          height="100%"
          width="100%"
          buttons={
            <>
              <Button.Checkbox
                checked={antag_events_enabled}
                tooltip="If checked, random events that spawn antags
                  or dynamic rulesets can trigger."
                onClick={() => act('toggle_antag_events')}
              >
                Antag Events
              </Button.Checkbox>
              <Button
                tooltip="Opens the Dynamic subsystem VV panel."
                onClick={() => act('dynamic_vv')}
              >
                VV
              </Button>
            </>
          }
        >
          <Tabs>
            {tabs_filtered.map((tab) => (
              <Tabs.Tab
                key={tab}
                selected={currentTab === tab}
                onClick={() => setCurrentTab(tab)}
              >
                {tab}
              </Tabs.Tab>
            ))}
          </Tabs>
          {componentShown}
        </Section>
      </Window.Content>
    </Window>
  );
};
