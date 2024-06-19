import { createSearch } from 'common/string';
import { useState } from 'react';

import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dropdown,
  Icon,
  Input,
  Section,
  Stack,
  Tabs,
} from '../components';
import { RADIO_CHANNELS } from '../constants';
import { Window } from '../layouts';

type ButtonData = {
  name: string;
  channel: string;
};

type ButtonDataWithId = {
  button: ButtonData;
  index: number;
};

type StringWithId = {
  string: string;
  index: number;
};

type BotAnnouncementData = {
  channels: string[];
  lines: string[];
  button_data: ButtonData[];
  cooldown_left: number;
};

enum TAB {
  Announcements,
  Shortcuts,
}

export const BotAnnouncement = (props) => {
  const { act, data } = useBackend<BotAnnouncementData>();
  const { channels, lines, button_data, cooldown_left } = data;

  const [tab, setTab] = useState(TAB.Announcements);
  const [selectedChannel, setSelectedChannel] = useState<null | string>(null);
  const [selectedLine, setSelectedLine] = useState<null | number>(null);
  const [selectedButton, setSelectedButton] = useState<null | number>(null);
  const [search, setSearch] = useState('');

  let filteredLines: StringWithId[] = lines.map((val, index) => ({
    string: val,
    index,
  }));
  let filteredShortcuts: ButtonDataWithId[] = button_data.map((val, index) => ({
    button: val,
    index,
  }));

  if (search !== '') {
    if (tab === TAB.Announcements) {
      const lineSearch = createSearch(
        search,
        (item: StringWithId) => item.string,
      );
      filteredLines = filteredLines.filter(lineSearch);
    } else {
      const buttonSearch = createSearch(
        search,
        (item: ButtonDataWithId) => item.button.name,
      );
      filteredShortcuts = filteredShortcuts.filter(buttonSearch);
    }
  }

  return (
    <Window width={650} height={500}>
      <Window.Content>
        <Section fitted m={0}>
          <Tabs>
            <Tabs.Tab
              selected={tab === TAB.Announcements}
              onClick={() => {
                setSearch('');
                setTab(TAB.Announcements);
              }}
            >
              Announcements
            </Tabs.Tab>
            <Tabs.Tab
              selected={tab === TAB.Shortcuts}
              onClick={() => {
                setSearch('');
                setTab(TAB.Shortcuts);
              }}
            >
              Shortcuts
            </Tabs.Tab>
          </Tabs>
        </Section>
        <Section m={0} scrollable fill maxHeight="350px">
          {tab === TAB.Announcements && (
            <Stack vertical zebra>
              {filteredLines.map((val) => (
                <Stack.Item key={val.string}>
                  <Button
                    py={1}
                    color={selectedLine === val.index ? 'green' : 'transparent'}
                    fluid
                    onClick={() => setSelectedLine(val.index)}
                    minHeight="32px"
                  >
                    <Stack>
                      <Stack.Item>
                        <Icon name="volume-high" />
                      </Stack.Item>
                      <Stack.Item>{val.string}</Stack.Item>
                    </Stack>
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          )}
          {tab === TAB.Shortcuts && (
            <Stack vertical zebra>
              {filteredShortcuts.map((val) => (
                <Stack.Item key={val.index}>
                  <Button
                    py={1}
                    color={
                      selectedButton === val.index ? 'green' : 'transparent'
                    }
                    fluid
                    onClick={() => setSelectedButton(val.index)}
                    minHeight="32px"
                  >
                    <Stack>
                      <Stack.Item>
                        <Icon name="volume-high" />
                      </Stack.Item>
                      <Stack.Item grow>{val.button.name}</Stack.Item>
                      <Stack.Item align="center">
                        <Box
                          color={
                            selectedButton === val.index
                              ? 'white'
                              : RADIO_CHANNELS.find(
                                  (channel) =>
                                    channel.name === val.button.channel,
                                )?.color
                          }
                        >
                          {val.button.channel || 'No radio channel'}
                        </Box>
                      </Stack.Item>
                    </Stack>
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          )}
        </Section>
        <Section>
          <Stack vertical>
            <Stack.Item>
              <Input
                onInput={(event, newValue) => setSearch(newValue)}
                fluid
                autoFocus
                placeholder="Search..."
              />
            </Stack.Item>
            <Stack.Item>
              <Stack align="center">
                {tab === TAB.Announcements ? (
                  <Stack.Item grow>
                    <Dropdown
                      options={['No radio channel', ...channels]}
                      displayText={
                        selectedChannel === null
                          ? 'No radio channel'
                          : selectedChannel
                      }
                      width="100%"
                      selected={selectedChannel}
                      onSelected={(value) => {
                        if (value === 'No radio channel') {
                          setSelectedChannel(null);
                        } else {
                          setSelectedChannel(value);
                        }
                      }}
                    />
                  </Stack.Item>
                ) : (
                  <Stack.Item grow />
                )}
                <Stack.Item>
                  <Button
                    textAlign="center"
                    onClick={() => {
                      if (tab === TAB.Announcements) {
                        if (selectedLine === null) {
                          return;
                        }
                        act('set_button', {
                          picked: lines[selectedLine],
                          channel: selectedChannel,
                        });
                      } else {
                        if (selectedButton === null) {
                          return;
                        }
                        act('remove_button', {
                          index: selectedButton + 1,
                        });
                      }
                    }}
                    color={tab === TAB.Announcements ? 'default' : 'red'}
                    minWidth="96px"
                  >
                    {tab === TAB.Announcements
                      ? 'Make Shortcut'
                      : 'Delete Shortcut'}
                  </Button>
                </Stack.Item>
                <Stack.Item>
                  <Button
                    textAlign="center"
                    onClick={() => {
                      if (tab === TAB.Announcements) {
                        if (selectedLine === null) {
                          return;
                        }
                        act('announce', {
                          picked: lines[selectedLine],
                          channel: selectedChannel,
                        });
                      } else {
                        if (selectedButton === null) {
                          return;
                        }
                        const button = button_data[selectedButton];
                        act('announce', {
                          picked: button.name,
                          channel: button.channel,
                        });
                      }
                    }}
                    disabled={cooldown_left > 0}
                    minWidth="96px"
                  >
                    Play{' '}
                    {cooldown_left > 0
                      ? `(${Math.round(cooldown_left / 10)}s)`
                      : ''}
                  </Button>
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
