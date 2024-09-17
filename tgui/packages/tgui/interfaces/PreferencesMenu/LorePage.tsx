import { useBackend } from "../../backend"
import { Box } from "../../components/Box"
import { LabeledList } from "../../components/LabeledList";
import { Section } from "../../components/Section";
import { Stack } from "../../components/Stack";
import { PreferencesMenuData } from "./data"
import { PreferenceSingle } from "./SinglePreference";

export const LorePage = () => {
  const { act, data } = useBackend<PreferencesMenuData>();
  const dopplerLorePreferences = {
    ...data.character_preferences.doppler_lore
  }
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
          <Section
           title="Character Details"
          >
            <PreferenceSingle
              act={act}
              pref_key="age"
              preferences={dopplerLorePreferences}
              maxHeight="auto"
            />
            <PreferenceSingle
              act={act}
              pref_key="age_chronological"
              preferences={dopplerLorePreferences}
              maxHeight="auto"
            />
            <PreferenceSingle
              act={act}
              pref_key="flavor_short_desc"
              preferences={dopplerLorePreferences}
              maxHeight="auto"
            />
            <PreferenceSingle
              act={act}
              pref_key="flavor_extended_desc"
              preferences={dopplerLorePreferences}
              maxHeight="auto"
            />
          </Section>
          <Section
           title="Species"
          >
            <PreferenceSingle
              act={act}
              pref_key="custom_species_name"
              preferences={dopplerLorePreferences}
              maxHeight="auto"
            />
            <PreferenceSingle
              act={act}
              pref_key="custom_species_desc"
              preferences={dopplerLorePreferences}
              maxHeight="auto"
            />
         </Section>
         <Section
          title="Records"
          >

          </Section>
        </LabeledList>
      </Stack.Item>
    </Box>
  );
}
