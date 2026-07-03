import { binaryInsertWith } from 'common/collections';
import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Button, Divider, Section, Stack, Tooltip } from 'tgui-core/components';
import { classes } from 'tgui-core/react';

import { type Antagonist, Category } from '../antagonists/base';
import type { PreferencesMenuData } from '../types';

const requireAntag = require.context(
  '../antagonists/antagonists',
  false,
  /.ts$/,
);

const antagsByCategory = new Map<Category, Antagonist[]>();

// This will break at priorities higher than 10, but that almost definitely
// will not happen.
function binaryInsertAntag(collection: Antagonist[], value: Antagonist) {
  return binaryInsertWith(collection, value, (antag) => {
    return `${antag.priority}_${antag.name}`;
  });
}

for (const antagKey of requireAntag.keys()) {
  const antag = requireAntag<{
    default?: Antagonist;
  }>(antagKey).default;

  if (!antag) {
    continue;
  }

  antagsByCategory.set(
    antag.category,
    binaryInsertAntag(antagsByCategory.get(antag.category) || [], antag),
  );
}

type AntagSelectionProps = {
  antagonists: Antagonist[];
  name: string;
};

function AntagSelection(props: AntagSelectionProps) {
  const { act, data } = useBackend<PreferencesMenuData>();
  const className = 'PreferencesMenu__AntagsSelection';

  const [predictedState, setPredictedState] = useState(
    new Set(data.selected_antags),
  );

  function enableAntags(antags: string[]) {
    const newState = new Set(predictedState);
    for (const antag of antags) {
      newState.add(antag);
    }

    setPredictedState(newState);
    act('set_antags', {
      antags,
      toggled: true,
    });
  }

  function disableAntags(antags: string[]) {
    const newState = new Set(predictedState);
    for (const antag of antags) {
      newState.delete(antag);
    }

    setPredictedState(newState);
    act('set_antags', {
      antags,
      toggled: false,
    });
  }

  const antagonistKeys = props.antagonists.map((antagonist) => antagonist.key);
  return (
    <Section
      title={props.name}
      buttons={
        <Stack>
          <Stack.Item>
            <Button color="good" onClick={() => enableAntags(antagonistKeys)}>
              Включить всё
            </Button>
          </Stack.Item>
          <Stack.Item>
            <Button color="bad" onClick={() => disableAntags(antagonistKeys)}>
              Отключить всё
            </Button>
          </Stack.Item>
        </Stack>
      }
    >
      <Stack className={className} wrap>
        {props.antagonists.map((antagonist) => {
          const isBanned =
            data.antag_bans && data.antag_bans.indexOf(antagonist.key) !== -1;

          const daysLeft = data.antag_days_left?.[antagonist.key] || 0;

          return (
            <Tooltip
              key={antagonist.key}
              position="bottom"
              content={
                isBanned
                  ? `У вас бан на ${antagonist.name}.`
                  : antagonist.description.map((text, index) => {
                      return (
                        <div key={antagonist.key + index}>
                          {text}
                          {index !== antagonist.description.length - 1 && (
                            <Divider />
                          )}
                        </div>
                      );
                    })
              }
            >
              <Stack
                vertical
                className={classes([
                  `${className}__Antag`,
                  isBanned || daysLeft > 0
                    ? 'banned'
                    : predictedState.has(antagonist.key)
                      ? 'on'
                      : 'off',
                ])}
                onClick={() => {
                  if (isBanned) {
                    return;
                  }

                  if (predictedState.has(antagonist.key)) {
                    disableAntags([antagonist.key]);
                  } else {
                    enableAntags([antagonist.key]);
                  }
                }}
              >
                <Stack.Item className={`${className}__AntagIcon--wrapper`}>
                  <Stack.Item
                    className={classes([
                      `${className}__AntagIcon`,
                      'antagonists96x96',
                      antagonist.key,
                    ])}
                  />
                  {isBanned && <div className={`${className}__AntagBan`} />}
                  {daysLeft > 0 && (
                    <Stack
                      fill
                      vertical
                      className={`${className}__AntagDaysLeft`}
                    >
                      <Stack.Item>Осталось дней</Stack.Item>
                      <Stack.Item bold>{daysLeft}</Stack.Item>
                    </Stack>
                  )}
                </Stack.Item>
                <Stack.Item className={`${className}__AntagName`}>
                  {antagonist.name}
                </Stack.Item>
              </Stack>
            </Tooltip>
          );
        })}
      </Stack>
    </Section>
  );
}

export function AntagsPage() {
  return (
    <Stack.Item className="PreferencesMenu__Antags">
      <AntagSelection
        name="Начало раунда"
        antagonists={antagsByCategory.get(Category.Roundstart)!}
      />

      <AntagSelection
        name="Во время раунда"
        antagonists={antagsByCategory.get(Category.Midround)!}
      />

      <AntagSelection
        name="Позднее прибытие"
        antagonists={antagsByCategory.get(Category.Latejoin)!}
      />
    </Stack.Item>
  );
}
