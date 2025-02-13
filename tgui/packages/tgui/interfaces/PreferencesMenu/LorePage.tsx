import { Box, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { PreferenceSingle } from './SinglePreference';
import { PreferencesMenuData } from './types';

export const LorePage = () => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const dopplerLorePreferences = {
    ...data.character_preferences.doppler_lore,
  };
  return (
    <Box className="PreferencesMenu__Lore">
      <Stack.Item
        basis="50%"
        grow
        style={{
          background: 'rgba(0, 0, 0, 0.5)',
          padding: '4px',
        }}
        overflowX="hidden"
        overflowY="auto"
        maxHeight="auto"
      >
        <LabeledList>
          <Section title="Character Details">
            <PreferenceSingle
              pref_key="age"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              pref_key="age_chronological"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              pref_key="flavor_short_desc"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              pref_key="flavor_extended_desc"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              pref_key="headshot_url"
              preferences={dopplerLorePreferences}
            />
          </Section>
          <Section title="Species">
            <PreferenceSingle
              pref_key="custom_species_name"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              pref_key="custom_species_desc"
              preferences={dopplerLorePreferences}
            />
          </Section>
          <Section title="Silicon">
            <PreferenceSingle
              pref_key="silicon_flavor_short_desc"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              pref_key="silicon_flavor_extended_desc"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              pref_key="silicon_model_name"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              pref_key="silicon_model_desc"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              pref_key="silicon_headshot_url"
              preferences={dopplerLorePreferences}
            />
          </Section>
          <Section title="Records">
            <PreferenceSingle
              pref_key="past_general_records"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              pref_key="past_medical_records"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              pref_key="past_security_records"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              pref_key="exploitable_records"
              preferences={dopplerLorePreferences}
            />
          </Section>
          <Section title="Notes">
            <PreferenceSingle
              pref_key="ooc_notes"
              preferences={dopplerLorePreferences}
            />
          </Section>
        </LabeledList>
      </Stack.Item>
    </Box>
  );
};
