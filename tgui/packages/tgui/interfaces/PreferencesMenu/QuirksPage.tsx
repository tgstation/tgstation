import { StatelessComponent } from 'inferno';
import { Box, Button, Icon, Stack, Tooltip } from '../../components';
import { PreferencesMenuData, Quirk, ServerData } from './data';
import { useBackend, useLocalState } from '../../backend';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';
import { filterMap } from 'common/collections';
import { getRandomization, PreferenceList } from './MainPage';

const getValueClass = (value: number): string => {
  if (value > 0) {
    return 'positive';
  } else if (value < 0) {
    return 'negative';
  } else {
    return 'neutral';
  }
};

const getCorrespondingPreferences = (
  customization_options: string[],
  all_preferences: Record<string, string>
): Record<string, unknown> => {
  return Object.fromEntries(
    filterMap(Object.keys(all_preferences), (key) => {
      if (!customization_options.includes(key)) {
        return undefined;
      }

      return [key, all_preferences[key]];
    })
  );
};

const QuirkList = (props: {
  quirks: [
    string,
    Quirk & {
      failTooltip?: string;
    }
  ][];
  onClick: (quirkName: string, quirk: Quirk) => void;
  onCustomizeClick: (e: Event, quirkName: string, quirk: Quirk) => void;
  selected: boolean;
  serverData: ServerData;
  randomBodyEnabled: boolean;
  context;
}) => {
  const { act, data } = useBackend<PreferencesMenuData>(props.context);

  return (
    // Stack is not used here for a variety of IE flex bugs
    <Box className="PreferencesMenu__Quirks__QuirkList">
      {props.quirks.map(([quirkKey, quirk]) => {
        const className = 'PreferencesMenu__Quirks__QuirkList__quirk';

        const child = (
          <Box
            className={className}
            key={quirkKey}
            role="button"
            tabIndex="1"
            onClick={() => {
              props.onClick(quirkKey, quirk);
            }}>
            <Stack fill>
              <Stack.Item
                align="center"
                style={{
                  'min-width': '15%',
                  'max-width': '15%',
                  'text-align': 'center',
                }}>
                <Icon color="#333" fontSize={3} name={quirk.icon} />
              </Stack.Item>

              <Stack.Item
                align="stretch"
                style={{
                  'border-right': '1px solid black',
                  'margin-left': 0,
                }}
              />

              <Stack.Item
                grow
                style={{
                  'margin-left': 0,

                  // Fixes an IE bug for text overflowing in Flex boxes
                  'min-width': '0%',
                }}>
                <Stack vertical fill>
                  <Stack.Item
                    className={`${className}--${getValueClass(quirk.value)}`}
                    style={{
                      'border-bottom': '1px solid black',
                      'padding': '2px',
                    }}>
                    <Stack
                      fill
                      style={{
                        'font-size': '1.2em',
                      }}>
                      <Stack.Item grow basis="content">
                        <b>{quirk.name}</b>
                      </Stack.Item>

                      <Stack.Item>
                        <b>{quirk.value}</b>
                      </Stack.Item>
                    </Stack>
                  </Stack.Item>

                  <Stack.Item
                    grow
                    basis="content"
                    style={{
                      'margin-top': 0,
                      'padding': '3px',
                    }}>
                    {quirk.description}
                    {!!quirk.customizable && (
                      <Button
                        disabled={!props.selected}
                        icon="cog"
                        tooltip={
                          !props.selected
                            ? 'You must take this quirk before you can customize it!'
                            : 'This quirk is customizable! Click this button to open a customization menu!'
                        }
                        onClick={(e: Event) => {
                          props.onCustomizeClick(e, quirkKey, quirk);
                        }}
                        style={{
                          'float': 'right',
                        }}
                      />
                    )}
                    {Object.entries(quirk.customization_options).length > 0 && (
                      <PreferenceList
                        act={act}
                        preferences={getCorrespondingPreferences(
                          quirk.customization_options,
                          data.character_preferences.all_preferences
                        )}
                        randomizations={getRandomization(
                          getCorrespondingPreferences(
                            quirk.customization_options,
                            data.character_preferences.all_preferences
                          ),
                          props.serverData,
                          props.randomBodyEnabled,
                          props.context
                        )}
                      />
                    )}
                  </Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Box>
        );

        if (quirk.failTooltip) {
          return <Tooltip content={quirk.failTooltip}>{child}</Tooltip>;
        } else {
          return child;
        }
      })}
    </Box>
  );
};

const StatDisplay: StatelessComponent<{}> = (props) => {
  return (
    <Box
      backgroundColor="#eee"
      bold
      color="black"
      fontSize="1.2em"
      px={3}
      py={0.5}>
      {props.children}
    </Box>
  );
};

export const QuirksPage = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);

  const randomToggleEnabled = false;

  const randomBodyEnabled = false;
  /* data.character_preferences.non_contextual.random_body !==
      RandomSetting.Disabled || randomToggleEnabled;*/

  const [selectedQuirks, setSelectedQuirks] = useLocalState(
    context,
    `selectedQuirks_${data.active_slot}`,
    data.selected_quirks
  );

  return (
    <ServerPreferencesFetcher
      render={(server_data) => {
        if (!server_data) {
          return <Box>Loading quirks...</Box>;
        }

        const {
          max_positive_quirks: maxPositiveQuirks,
          quirk_blacklist: quirkBlacklist,
          quirk_info: quirkInfo,
        } = server_data.quirks;

        const quirks = Object.entries(quirkInfo);
        quirks.sort(([_, quirkA], [__, quirkB]) => {
          if (quirkA.value === quirkB.value) {
            return quirkA.name > quirkB.name ? 1 : -1;
          } else {
            return quirkA.value - quirkB.value;
          }
        });

        let balance = 0;
        let positiveQuirks = 0;

        for (const selectedQuirkName of selectedQuirks) {
          const selectedQuirk = quirkInfo[selectedQuirkName];
          if (!selectedQuirk) {
            continue;
          }

          if (selectedQuirk.value > 0) {
            positiveQuirks += 1;
          }

          balance += selectedQuirk.value;
        }

        const getReasonToNotAdd = (quirkName: string) => {
          const quirk = quirkInfo[quirkName];

          if (quirk.value > 0) {
            if (positiveQuirks >= maxPositiveQuirks) {
              return "You can't have any more positive quirks!";
            } else if (balance + quirk.value > 0) {
              return 'You need a negative quirk to balance this out!';
            }
          }

          const selectedQuirkNames = selectedQuirks.map((quirkKey) => {
            return quirkInfo[quirkKey].name;
          });

          for (const blacklist of quirkBlacklist) {
            if (blacklist.indexOf(quirk.name) === -1) {
              continue;
            }

            for (const incompatibleQuirk of blacklist) {
              if (
                incompatibleQuirk !== quirk.name &&
                selectedQuirkNames.indexOf(incompatibleQuirk) !== -1
              ) {
                return `This is incompatible with ${incompatibleQuirk}!`;
              }
            }
          }

          return undefined;
        };

        const getReasonToNotRemove = (quirkName: string) => {
          const quirk = quirkInfo[quirkName];

          if (balance - quirk.value > 0) {
            return 'You need to remove a positive quirk first!';
          }

          return undefined;
        };

        return (
          <Stack align="center" fill>
            <Stack.Item basis="50%">
              <Stack vertical fill align="center">
                <Stack.Item>
                  <Box fontSize="1.3em">Positive Quirks</Box>
                </Stack.Item>

                <Stack.Item>
                  <StatDisplay>
                    {positiveQuirks} / {maxPositiveQuirks}
                  </StatDisplay>
                </Stack.Item>

                <Stack.Item>
                  <Box as="b" fontSize="1.6em">
                    Available Quirks
                  </Box>
                </Stack.Item>

                <Stack.Item grow width="100%">
                  <QuirkList
                    selected={false}
                    onClick={(quirkName, quirk) => {
                      if (getReasonToNotAdd(quirkName) !== undefined) {
                        return;
                      }

                      setSelectedQuirks(selectedQuirks.concat(quirkName));

                      act('give_quirk', { quirk: quirk.name });
                    }}
                    onCustomizeClick={(e: Event, quirkName, quirk) => {
                      e.stopPropagation();

                      act('customize_quirk', { quirk: quirk.name });
                    }}
                    quirks={quirks
                      .filter(([quirkName, _]) => {
                        return selectedQuirks.indexOf(quirkName) === -1;
                      })
                      .map(([quirkName, quirk]) => {
                        return [
                          quirkName,
                          {
                            ...quirk,
                            failTooltip: getReasonToNotAdd(quirkName),
                          },
                        ];
                      })}
                    serverData={server_data}
                    randomBodyEnabled={randomBodyEnabled}
                    context={context}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>

            <Stack.Item>
              <Icon name="exchange-alt" size={1.5} ml={2} mr={2} />
            </Stack.Item>

            <Stack.Item basis="50%">
              <Stack vertical fill align="center">
                <Stack.Item>
                  <Box fontSize="1.3em">Quirk Balance</Box>
                </Stack.Item>

                <Stack.Item>
                  <StatDisplay>{balance}</StatDisplay>
                </Stack.Item>

                <Stack.Item>
                  <Box as="b" fontSize="1.6em">
                    Current Quirks
                  </Box>
                </Stack.Item>

                <Stack.Item grow width="100%">
                  <QuirkList
                    selected
                    onClick={(quirkName, quirk) => {
                      if (getReasonToNotRemove(quirkName) !== undefined) {
                        return;
                      }

                      setSelectedQuirks(
                        selectedQuirks.filter(
                          (otherQuirk) => quirkName !== otherQuirk
                        )
                      );

                      act('remove_quirk', { quirk: quirk.name });
                    }}
                    onCustomizeClick={(e: Event, quirkName, quirk) => {
                      e.stopPropagation();

                      quirk.customization_expanded = true;

                      act('customize_quirk', { quirk: quirk.name });
                    }}
                    quirks={quirks
                      .filter(([quirkName, _]) => {
                        return selectedQuirks.indexOf(quirkName) !== -1;
                      })
                      .map(([quirkName, quirk]) => {
                        return [
                          quirkName,
                          {
                            ...quirk,
                            failTooltip: getReasonToNotRemove(quirkName),
                          },
                        ];
                      })}
                    serverData={server_data}
                    randomBodyEnabled={randomBodyEnabled}
                    context={context}
                  />
                </Stack.Item>
              </Stack>
            </Stack.Item>
          </Stack>
        );
      }}
    />
  );
};
