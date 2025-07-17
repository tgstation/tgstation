import { filter } from 'es-toolkit/compat';
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Floating,
  Icon,
  Input,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { createSearch } from 'tgui-core/string';

import {
  type PreferencesMenuData,
  type Quirk,
  RandomSetting,
  type ServerData,
} from '../types';
import { useRandomToggleState } from '../useRandomToggleState';
import { useServerPrefs } from '../useServerPrefs';
import { getRandomization, PreferenceList } from './MainPage';

function getColorValueClass(quirk: Quirk) {
  if (quirk.value > 0) {
    return 'positive';
  } else if (quirk.value < 0) {
    return 'negative';
  } else {
    return 'neutral';
  }
}

function getCorrespondingPreferences(
  customization_options: string[],
  relevant_preferences: Record<string, string>,
) {
  return Object.fromEntries(
    filter(Object.entries(relevant_preferences), ([key, value]) =>
      customization_options.includes(key),
    ),
  );
}

type QuirkEntry = [string, Quirk & { failTooltip?: string }];

type QuirkListProps = {
  quirks: QuirkEntry[];
};

type QuirkProps = {
  // eslint-disable-next-line react/no-unused-prop-types
  onClick: (quirkName: string, quirk: Quirk) => void;
  randomBodyEnabled: boolean;
  selected: boolean;
  serverData: ServerData;
};

function QuirkList(props: QuirkProps & QuirkListProps) {
  const {
    quirks = [],
    selected,
    onClick,
    serverData,
    randomBodyEnabled,
  } = props;

  return (
    <Stack vertical g={0}>
      {quirks.map(([quirkKey, quirk]) => (
        <Stack.Item key={quirkKey} m={0}>
          <QuirkDisplay
            onClick={onClick}
            quirk={quirk}
            quirkKey={quirkKey}
            randomBodyEnabled={randomBodyEnabled}
            selected={selected}
            serverData={serverData}
          />
        </Stack.Item>
      ))}
    </Stack>
  );
}

type QuirkDisplayProps = {
  quirk: Quirk & { failTooltip?: string };
  // bugged
  // eslint-disable-next-line react/no-unused-prop-types
  quirkKey: string;
} & QuirkProps;

function QuirkDisplay(props: QuirkDisplayProps) {
  const { quirk, quirkKey, onClick, selected } = props;
  const { icon, value, name, description, customizable, failTooltip } = quirk;

  const [customizationExpanded, setCustomizationExpanded] = useState(false);

  const className = 'PreferencesMenu__Quirks__QuirkList__quirk';

  const child = (
    <Box
      className={className}
      onClick={(event) => {
        event.stopPropagation();
        if (selected) {
          setCustomizationExpanded(false);
        }

        onClick(quirkKey, quirk);
      }}
    >
      <Stack fill g={0}>
        <Stack.Item
          align="center"
          style={{
            minWidth: '15%',
            maxWidth: '15%',
            textAlign: 'center',
          }}
        >
          <Icon color="#333" fontSize={3} name={icon} />
        </Stack.Item>

        <Stack.Item
          align="stretch"
          ml={0}
          style={{
            borderRight: '1px solid black',
          }}
        />

        <Stack.Item
          grow
          ml={0}
          style={{
            // Fixes an IE bug for text overflowing in Flex boxes
            minWidth: '0%',
          }}
        >
          <Stack vertical fill>
            <Stack.Item
              className={`${className}--${getColorValueClass(quirk)}`}
              style={{
                borderBottom: '1px solid black',
                padding: '2px',
              }}
            >
              <Stack
                fill
                style={{
                  fontSize: '1.2em',
                }}
              >
                <Stack.Item grow basis="content">
                  <b>{name}</b>
                </Stack.Item>

                <Stack.Item>
                  <b>{value}</b>
                </Stack.Item>
              </Stack>
            </Stack.Item>

            <Stack.Item
              grow
              basis="content"
              mt={0}
              style={{
                padding: '3px',
              }}
            >
              {description}
              {!!customizable && (
                <QuirkPopper
                  {...props}
                  customizationExpanded={customizationExpanded}
                  setCustomizationExpanded={setCustomizationExpanded}
                />
              )}
            </Stack.Item>
          </Stack>
        </Stack.Item>
      </Stack>
    </Box>
  );

  if (failTooltip) {
    return <Tooltip content={failTooltip}>{child}</Tooltip>;
  } else {
    return child;
  }
}

type QuirkPopperProps = {
  customizationExpanded: boolean;
  setCustomizationExpanded: (expanded: boolean) => void;
} & QuirkDisplayProps;

function QuirkPopper(props: QuirkPopperProps) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const {
    customizationExpanded,
    quirk,
    randomBodyEnabled,
    selected,
    serverData,
    setCustomizationExpanded,
  } = props;

  const { customizable, customization_options } = quirk;

  const { character_preferences } = data;

  const hasExpandableCustomization =
    customizable &&
    selected &&
    customization_options &&
    Object.entries(customization_options).length > 0;

  return (
    <Floating
      stopChildPropagation
      placement="bottom-end"
      onOpenChange={setCustomizationExpanded}
      content={
        hasExpandableCustomization && (
          <Box
            onClick={(e) => {
              e.stopPropagation();
            }}
            style={{
              boxShadow: '0px 4px 8px 3px rgba(0, 0, 0, 0.7)',
            }}
          >
            <Stack maxWidth="300px" backgroundColor="black" px="5px" py="3px">
              <Stack.Item>
                <PreferenceList
                  preferences={getCorrespondingPreferences(
                    customization_options,
                    character_preferences.manually_rendered_features,
                  )}
                  randomizations={getRandomization(
                    getCorrespondingPreferences(
                      customization_options,
                      character_preferences.manually_rendered_features,
                    ),
                    serverData,
                    randomBodyEnabled,
                  )}
                  maxHeight="100px"
                />
              </Stack.Item>
            </Stack>
          </Box>
        )
      }
    >
      <div style={{ display: 'flow-root' }}>
        {selected && (
          <Button
            selected={customizationExpanded}
            icon="cog"
            tooltip="Customize"
            style={{
              float: 'right',
            }}
          />
        )}
      </div>
    </Floating>
  );
}

function StatDisplay(props) {
  const { children } = props;

  return (
    <Box
      backgroundColor="#eee"
      bold
      color="black"
      fontSize="1.2em"
      px={3}
      py={0.5}
    >
      {children}
    </Box>
  );
}

export function QuirksPage(props) {
  const { act, data } = useBackend<PreferencesMenuData>();

  // this is mainly just here to copy from MainPage.tsx
  const [randomToggleEnabled] = useRandomToggleState();
  const randomBodyEnabled =
    data.character_preferences.non_contextual.random_body !==
      RandomSetting.Disabled || randomToggleEnabled;

  const selectedQuirks = data.selected_quirks;
  function setSelectedQuirks(selected_quirks) {
    data.selected_quirks = selected_quirks;
  }

  const [searchQuery, setSearchQuery] = useState('');
  const server_data = useServerPrefs();
  if (!server_data) return;
  const quirkSearch = createSearch(searchQuery, (quirk: Quirk) => quirk.name);
  const {
    max_positive_quirks: maxPositiveQuirks,
    quirk_blacklist: quirkBlacklist,
    quirk_info: quirkInfo,
    points_enabled: pointsEnabled,
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

  function getReasonToNotAdd(quirkName: string) {
    const quirk = quirkInfo[quirkName];

    if (quirk.value > 0) {
      if (maxPositiveQuirks !== -1 && positiveQuirks >= maxPositiveQuirks) {
        return "You can't have any more positive quirks!";
      } else if (pointsEnabled && balance + quirk.value > 0) {
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
    if (data.species_disallowed_quirks.includes(quirk.name)) {
      return 'This quirk is incompatible with your selected species.';
    }
    return;
  }

  function getReasonToNotRemove(quirkName: string) {
    const quirk = quirkInfo[quirkName];

    if (pointsEnabled && balance - quirk.value > 0) {
      return 'You need to remove a positive quirk first!';
    }

    return;
  }

  return (
    <Stack fill>
      <Stack.Item basis="50%">
        <Stack vertical fill align="center">
          <Stack.Item>
            {maxPositiveQuirks > 0 ? (
              <Box fontSize="1.3em">Positive Quirks</Box>
            ) : (
              <Box mt={pointsEnabled ? 3.4 : 0} />
            )}
          </Stack.Item>

          <Stack.Item>
            {maxPositiveQuirks > 0 ? (
              <StatDisplay>
                {positiveQuirks} / {maxPositiveQuirks}
              </StatDisplay>
            ) : (
              <Box mt={pointsEnabled ? 3.4 : 0} />
            )}
          </Stack.Item>

          <Stack.Item>
            <Box as="b" fontSize="1.6em">
              Available Quirks
            </Box>
          </Stack.Item>
          <Stack.Item>
            <Input
              placeholder="Search quirks..."
              width="200px"
              value={searchQuery}
              onChange={setSearchQuery}
            />
          </Stack.Item>
          <Stack.Item grow className="PreferencesMenu__Quirks__QuirkList">
            <QuirkList
              selected={false}
              onClick={(quirkName, quirk) => {
                if (getReasonToNotAdd(quirkName) !== undefined) {
                  return;
                }

                setSelectedQuirks(selectedQuirks.concat(quirkName));

                act('give_quirk', { quirk: quirk.name });
              }}
              quirks={quirks
                .filter(([quirkName, _]) => {
                  return (
                    selectedQuirks.indexOf(quirkName) === -1 &&
                    quirkSearch(quirkInfo[quirkName])
                  );
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
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>

      <Stack.Item align="center">
        <Icon name="exchange-alt" size={1.5} ml={2} mr={2} />
      </Stack.Item>

      <Stack.Item basis="50%">
        <Stack vertical fill align="center">
          <Stack.Item>
            {pointsEnabled ? (
              <Box fontSize="1.3em">Quirk Balance</Box>
            ) : (
              <Box mt={maxPositiveQuirks > 0 ? 3.4 : 0} />
            )}
          </Stack.Item>
          <Stack.Item>
            {pointsEnabled ? (
              <StatDisplay>{balance}</StatDisplay>
            ) : (
              <Box mt={maxPositiveQuirks > 0 ? 3.4 : 0} />
            )}
          </Stack.Item>
          <Stack.Item>
            <Box as="b" fontSize="1.6em">
              Current Quirks
            </Box>
          </Stack.Item>
          <Stack.Item p={1.5} /> {/* Filler to better align the menu*/}
          <Stack.Item grow className="PreferencesMenu__Quirks__QuirkList">
            <QuirkList
              selected
              onClick={(quirkName, quirk) => {
                if (getReasonToNotRemove(quirkName) !== undefined) {
                  return;
                }

                setSelectedQuirks(
                  selectedQuirks.filter(
                    (otherQuirk) => quirkName !== otherQuirk,
                  ),
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
                      failTooltip: getReasonToNotRemove(quirkName),
                    },
                  ];
                })}
              serverData={server_data}
              randomBodyEnabled={randomBodyEnabled}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
}
