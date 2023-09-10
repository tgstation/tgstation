import { StatelessComponent } from 'inferno';
import { Box, Icon, Stack, Tooltip } from '../../components';
import { PreferencesMenuData, Quirk } from './data';
import { useBackend, useLocalState } from '../../backend';
import { ServerPreferencesFetcher } from './ServerPreferencesFetcher';

const QuirkList = (props: {
  quirks: [
    string,
    Quirk & {
      failTooltip?: string;
    }
  ][];
  onClick: (quirkName: string, quirk: Quirk) => void;
}) => {
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

  const [selectedQuirks, setSelectedQuirks] = useLocalState(
    context,
    `selectedQuirks_${data.active_slot}`,
    data.selected_quirks
  );

  return (
    <ServerPreferencesFetcher
      render={(data) => {
        if (!data) {
          return <Box>Loading quirks...</Box>;
        }

        const {
          max_quirks: maxQuirks,
          quirk_blacklist: quirkBlacklist,
          quirk_info: quirkInfo,
        } = data.quirks;

        const quirks = Object.entries(quirkInfo);
        quirks.sort(([_, quirkA], [__, quirkB]) => {
          return quirkA.name > quirkB.name ? 1 : -1;
        });

        let totalQuirks = 0;
        for (const selectedQuirkName of selectedQuirks) {
          totalQuirks += 1;
        }
        const getReasonToNotAdd = (quirkName: string) => {
          const quirk = quirkInfo[quirkName];

          if (totalQuirks >= maxQuirks) {
            return "You can't have any more quirks!";
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

        return (
          <Stack align="center" fill>
            <Stack.Item basis="50%">
              <Stack vertical fill align="center">
                <Stack.Item>
                  <Box fontSize="1.3em">Positive Quirks</Box>
                </Stack.Item>

                <Stack.Item>
                  <StatDisplay>
                    {totalQuirks} / {maxQuirks}
                  </StatDisplay>
                </Stack.Item>

                <Stack.Item>
                  <Box as="b" fontSize="1.6em">
                    Available Quirks
                  </Box>
                </Stack.Item>

                <Stack.Item grow width="100%">
                  <QuirkList
                    onClick={(quirkName, quirk) => {
                      if (getReasonToNotAdd(quirkName) !== undefined) {
                        return;
                      }

                      setSelectedQuirks(selectedQuirks.concat(quirkName));

                      act('give_quirk', { quirk: quirk.name });
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
                  <Box as="b" fontSize="1.6em">
                    Current Quirks
                  </Box>
                </Stack.Item>

                <Stack.Item grow width="100%">
                  <QuirkList
                    onClick={(quirkName, quirk) => {
                      setSelectedQuirks(
                        selectedQuirks.filter(
                          (otherQuirk) => quirkName !== otherQuirk
                        )
                      );

                      act('remove_quirk', { quirk: quirk.name });
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
                          },
                        ];
                      })}
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
