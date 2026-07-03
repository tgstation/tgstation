import { useBackend } from 'tgui/backend';

import { RandomizationButton } from '../../components/RandomizationButton';
import { type PreferencesMenuData, RandomSetting } from '../../types';
import { CheckboxInput, type Feature, type FeatureToggle } from './base';

export const random_hardcore: FeatureToggle = {
  name: 'Тотальный рандом',
  component: CheckboxInput,
};

export const random_body: Feature<RandomSetting> = {
  name: 'Случайное тело',
  component: (props) => {
    return (
      <RandomizationButton
        setValue={(value) => props.handleSetValue(value)}
        value={props.value}
      />
    );
  },
};

export const random_name: Feature<RandomSetting> = {
  name: 'Случайное имя',
  component: (props) => {
    return (
      <RandomizationButton
        setValue={(value) => props.handleSetValue(value)}
        value={props.value}
      />
    );
  },
};

export const random_species: Feature<RandomSetting> = {
  name: 'Случайный вид',
  component: (props) => {
    const { act, data } = useBackend<PreferencesMenuData>();
    const species = data.character_preferences.randomization.species;

    return (
      <RandomizationButton
        setValue={(newValue) =>
          act('set_random_preference', {
            preference: 'species',
            value: newValue,
          })
        }
        value={species || RandomSetting.Disabled}
      />
    );
  },
};

// BANDASTATION ADDITION START - TTS
export const random_tts_seed: Feature<RandomSetting> = {
  name: 'Случайный голос',
  component: (props) => {
    const { act, data } = useBackend<PreferencesMenuData>();
    const tts_seed = data.character_preferences.randomization.tts_seed;

    return (
      <RandomizationButton
        setValue={(newValue) =>
          act('set_random_preference', {
            preference: 'tts_seed',
            value: newValue,
          })
        }
        value={tts_seed || RandomSetting.Disabled}
      />
    );
  },
};
// BANDASTATION ADDITION END - TTS
