import { binaryInsertWith } from 'common/collections';
import { sortBy } from 'es-toolkit';
import type { ReactNode } from 'react';
import { useBackend } from 'tgui/backend';
import { Stack } from 'tgui-core/components';

import { Preference } from '../components/Preference';
import { features } from '../preferences/features';
import { FeatureValueInput } from '../preferences/features/base';
import type { PreferencesMenuData } from '../types';
import { TabbedMenu } from './TabbedMenu';

export type PreferenceChild = {
  name: string;
  children: ReactNode;
};

function binaryInsertPreference(
  collection: PreferenceChild[],
  value: PreferenceChild,
) {
  return binaryInsertWith(collection, value, (child) => child.name);
}

function sortByName(array: [string, PreferenceChild[]][]) {
  return sortBy(array, [([name]) => name]);
}

export function GamePreferencesPage(props) {
  const { data } = useBackend<PreferencesMenuData>();

  const gamePreferences: Record<string, PreferenceChild[]> = {};
  for (const [featureId, value] of Object.entries(
    data.character_preferences.game_preferences,
  )) {
    const feature = features[featureId];
    const child = (
      <Preference
        key={featureId}
        id={featureId}
        name={feature.name}
        description={feature.description}
      >
        {feature ? (
          <FeatureValueInput
            feature={feature}
            featureId={featureId}
            value={value}
          />
        ) : (
          <Stack.Item grow bold color="red">
            ...is not filled out properly!!!
          </Stack.Item>
        )}
      </Preference>
    );

    const entry = {
      name: feature?.name || featureId,
      children: child,
    };

    const category = feature?.category || 'ERROR';
    gamePreferences[category] = binaryInsertPreference(
      gamePreferences[category] || [],
      entry,
    );
  }

  const gamePreferenceEntries: [string, PreferenceChild[]][] = sortByName(
    Object.entries(gamePreferences),
  ).map(([category, preferences]) => {
    return [category, preferences.map((entry) => entry)];
  });

  return (
    <Stack fill vertical>
      <TabbedMenu categories={gamePreferenceEntries} />
    </Stack>
  );
}
