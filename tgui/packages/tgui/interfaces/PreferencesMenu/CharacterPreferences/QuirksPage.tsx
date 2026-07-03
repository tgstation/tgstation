import { filter } from 'es-toolkit/compat';
import type { ReactNode } from 'react';
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import {
  Box,
  Button,
  Floating,
  Icon,
  Input,
  ProgressBar,
  Section,
  Stack,
  Tooltip,
} from 'tgui-core/components';
import { classes } from 'tgui-core/react';
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
import { PersonalityPage } from './PersonalityPage';

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
    <Stack vertical>
      {quirks.map(([quirkKey, quirk]) => (
        <QuirkDisplay
          key={quirkKey}
          quirk={quirk}
          quirkKey={quirkKey}
          randomBodyEnabled={randomBodyEnabled}
          selected={selected}
          serverData={serverData}
          onClick={onClick}
        />
      ))}
    </Stack>
  );
}

type QuirkDisplayProps = {
  quirk: Quirk & { failTooltip?: string };
  // bugged
  quirkKey: string;
} & QuirkProps;

function QuirkDisplay(props: QuirkDisplayProps) {
  const { quirk, quirkKey, onClick, selected } = props;
  const { icon, value, name, description, customizable, failTooltip } = quirk;

  const className = 'PreferencesMenu__QuirksQuirk';
  const [customizationExpanded, setCustomizationExpanded] = useState(false);
  const child = (
    <Stack
      fill
      g={0}
      className={classes([
        className,
        getColorValueClass(quirk),
        failTooltip && 'Unremovable',
      ])}
      onClick={(event) => {
        event.stopPropagation();
        if (selected) {
          setCustomizationExpanded(false);
        }

        onClick(quirkKey, quirk);
      }}
    >
      <Stack.Item className={`${className}--Icon`}>
        <Icon fontSize={3} name={icon} />
      </Stack.Item>
      <Stack.Item grow>
        <Stack fill vertical g={0}>
          <Stack fill bold className={`${className}--Name`}>
            <Stack.Item grow>{name}</Stack.Item>
            <Stack.Item>{value}</Stack.Item>
          </Stack>
          <Stack.Item grow className={`${className}--Desc`}>
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
  const { character_preferences } = data;
  const {
    customizationExpanded,
    quirk,
    randomBodyEnabled,
    selected,
    serverData,
    setCustomizationExpanded,
  } = props;
  const { customizable, customization_options } = quirk;
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
          <Stack.Item
            className="PreferencesMenu__QuirksQuirk--Customization"
            onClick={(e) => {
              e.stopPropagation();
            }}
          >
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
            />
          </Stack.Item>
        )
      }
    >
      <Box style={{ float: 'right' }}>
        {selected && (
          <Button
            icon="cog"
            tooltip="Настроить"
            selected={customizationExpanded}
          />
        )}
      </Box>
    </Floating>
  );
}

type StatDisplayProps = {
  value: number;
  maxValue?: number;
  children: ReactNode;
};

function StatDisplay(props: StatDisplayProps) {
  const { children, value, maxValue } = props;
  return (
    <ProgressBar
      value={value}
      maxValue={maxValue}
      ranges={
        maxValue
          ? {
              good: [-Infinity, maxValue * 0.5],
              average: [maxValue * 0.5, maxValue * 0.75],
              bad: [maxValue * 0.75, Infinity],
            }
          : {
              good: [0, Infinity],
              bad: [-Infinity, 0],
            }
      }
    >
      <Stack fill textAlign="left">
        <Stack.Item grow>{children}</Stack.Item>
        <Stack.Item>
          {value} {maxValue ? `/ ${maxValue}` : ''}
        </Stack.Item>
      </Stack>
    </ProgressBar>
  );
}

function QuirkPage() {
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

  let balance = -data.default_quirk_balance;
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
        return 'Вы не можете иметь еще больше позитивных черт!';
      } else if (pointsEnabled && balance + quirk.value > 0) {
        return 'Вам нужна отрицательная черта, чтобы получить очки!';
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
          return `Несовместимо с ${incompatibleQuirk}!`;
        }
      }
    }
    if (data.species_disallowed_quirks.includes(quirk.name)) {
      return 'Эта черта несовместима с выбранной расой.';
    }
    return;
  }

  function getReasonToNotRemove(quirkName: string) {
    const quirk = quirkInfo[quirkName];
    if (pointsEnabled && balance - quirk.value > 0) {
      return 'Нужно убрать позитивную черту!';
    }
  }

  const availableQuirls = (
    <Stack fill vertical>
      <Stack.Item>
        {maxPositiveQuirks > 0 && (
          <StatDisplay value={positiveQuirks} maxValue={maxPositiveQuirks}>
            Позитивные черты
          </StatDisplay>
        )}
      </Stack.Item>
      <Stack.Item grow className="PreferencesMenu__Quirks">
        <Section
          fill
          scrollable
          title="Доступные черты"
          buttons={
            <Input
              placeholder="Поиск черт..."
              width="200px"
              value={searchQuery}
              onChange={setSearchQuery}
            />
          }
        >
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
        </Section>
      </Stack.Item>
    </Stack>
  );

  const currentQuirks = (
    <Stack fill vertical>
      <Stack.Item>
        {pointsEnabled && (
          <StatDisplay value={balance}>Баланс черт</StatDisplay>
        )}
      </Stack.Item>
      <Stack.Item grow className={classes(['PreferencesMenu__Quirks'])}>
        <Section fill scrollable title="Текущие черты">
          <QuirkList
            selected
            onClick={(quirkName, quirk) => {
              if (getReasonToNotRemove(quirkName) !== undefined) {
                return;
              }

              setSelectedQuirks(
                selectedQuirks.filter((otherQuirk) => quirkName !== otherQuirk),
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
        </Section>
      </Stack.Item>
    </Stack>
  );

  return (
    <Stack fill>
      <Stack.Item grow>{availableQuirls}</Stack.Item>
      <Stack.Item grow>{currentQuirks}</Stack.Item>
    </Stack>
  );
}

export function QuirkPersonalityPage() {
  const [contentPage, setContentPage] = useState<'quirks' | 'personality'>(
    'quirks',
  );

  return (
    <Stack fill vertical>
      <Stack.Item>
        <Stack>
          <Stack.Item grow>
            <Button
              selected={contentPage === 'quirks'}
              onClick={() => setContentPage('quirks')}
              fluid
              align="center"
              fontSize="14px"
            >
              Quirks
            </Button>
          </Stack.Item>
          <Stack.Item grow>
            <Button
              selected={contentPage === 'personality'}
              onClick={() => setContentPage('personality')}
              fluid
              align="center"
              fontSize="14px"
            >
              Personality
            </Button>
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow>
        {contentPage === 'personality' ? <PersonalityPage /> : <QuirkPage />}
      </Stack.Item>
    </Stack>
  );
}
