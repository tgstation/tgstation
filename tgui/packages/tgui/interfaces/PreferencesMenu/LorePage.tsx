import { Box, LabeledList, Section, Stack } from 'tgui-core/components';

import { useBackend } from '../../backend';
import { PreferencesMenuData } from './data';
import { PreferenceSingle } from './SinglePreference';

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
              act={act}
              pref_key="age"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              act={act}
              pref_key="age_chronological"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              act={act}
              pref_key="flavor_short_desc"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              act={act}
              pref_key="flavor_extended_desc"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              act={act}
              pref_key="headshot_url"
              preferences={dopplerLorePreferences}
            />
          </Section>
          <Section title="Species">
            <PreferenceSingle
              act={act}
              pref_key="custom_species_name"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              act={act}
              pref_key="custom_species_desc"
              preferences={dopplerLorePreferences}
            />
          </Section>
          <Section title="Silicon">
            <PreferenceSingle
              act={act}
              pref_key="silicon_flavor_short_desc"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              act={act}
              pref_key="silicon_flavor_extended_desc"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              act={act}
              pref_key="silicon_model_name"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              act={act}
              pref_key="silicon_model_desc"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              act={act}
              pref_key="silicon_headshot_url"
              preferences={dopplerLorePreferences}
            />
          </Section>
          <Section title="Records">
            <PreferenceSingle
              act={act}
              pref_key="past_general_records"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              act={act}
              pref_key="past_medical_records"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              act={act}
              pref_key="past_security_records"
              preferences={dopplerLorePreferences}
            />
            <PreferenceSingle
              act={act}
              pref_key="exploitable_records"
              preferences={dopplerLorePreferences}
            />
          </Section>
          <Section title="Notes">
            <PreferenceSingle
              act={act}
              pref_key="ooc_notes"
              preferences={dopplerLorePreferences}
            />
          </Section>
        </LabeledList>
      </Stack.Item>
    </Box>
  );
};
