import { useBackend } from "../../backend";
import { Box, Button, Icon, Section, Stack, Tooltip } from "../../components";
import { CharacterPreview } from "./CharacterPreview";
import { createSetPreference, PreferencesMenuData } from "./data";
import { Feature, Species, fallbackSpecies } from "./preferences/species/base";

// MOTHBLOCKS TODO: Derive this
const SPECIES = ["human", "moth", "lizard", "ethereal"];

const requireSpecies = require.context("./preferences/species");

const SpeciesFeature = (props: {
  className: string,
  feature: Feature,
}) => {
  const { className, feature } = props;

  return (
    <Tooltip position="bottom-end" content={
      <Box>
        <b>{feature.name}</b>
        <p>{feature.description}</p>
      </Box>
    }>
      <Box class={className} width="32px" height="32px">
        <Icon
          name={feature.icon}
          size={1.5}
          ml={0}
          mt={1}
          style={{
            "text-align": "center",
            height: "100%",
            width: "100%",
          }}
        />
      </Box>
    </Tooltip>
  );
};

const SpeciesFeatures = (props: {
  features: Species["features"],
}) => {
  const { good, neutral, bad } = props.features;

  return (
    <Stack fill justify="space-between">
      <Stack.Item>
        <Stack>
          {good.map(feature => {
            return (
              <Stack.Item key={feature.name}>
                <SpeciesFeature
                  className="color-bg-green"
                  feature={feature} />
              </Stack.Item>
            );
          })}
        </Stack>
      </Stack.Item>

      <Stack grow>
        {neutral.map(feature => {
          return (
            <Stack.Item key={feature.name}>
              <SpeciesFeature
                className="color-bg-grey"
                feature={feature} />
            </Stack.Item>
          );
        })}
      </Stack>

      <Stack>
        {bad.map(feature => {
          return (
            <Stack.Item key={feature.name}>
              <SpeciesFeature
                className="color-bg-red"
                feature={feature} />
            </Stack.Item>
          );
        })}
      </Stack>
    </Stack>
  );
};

export const SpeciesPage = (props, context) => {
  const { act, data } = useBackend<PreferencesMenuData>(context);
  const setSpecies = createSetPreference(act, "species");

  const species: [string, Species][] = SPECIES
    .map((species) => [
      species,
      requireSpecies.keys().indexOf(`./${species}`) === -1
        ? fallbackSpecies
        : requireSpecies(`./${species}`).default,
    ]);

  const currentSpecies = species.filter(([speciesKey]) => {
    return speciesKey === data.character_preferences.misc.species;
  })[0][1];

  return (
    <Stack fill>
      <Stack.Item>
        <Stack vertical fill>
          {species.map(([speciesKey, species]) => {
            return (
              <Stack.Item key={speciesKey}>
                <Button
                  onClick={() => setSpecies(speciesKey)}
                  selected={
                    data.character_preferences.misc.species === speciesKey
                  }
                  tooltip="MOTHBLOCKS TODO: Derive name from server"
                  style={{
                    height: "32px",
                    width: "32px",
                  }}
                >
                  <Icon
                    className="centered-image"
                    name={species.icon}
                    size={2}
                    ml={0}
                    mt={0.5}
                    style={{
                      "text-align": "center",
                      height: "100%",
                      width: "100%",
                    }}
                  />
                </Button>
              </Stack.Item>
            );
          })}
        </Stack>
      </Stack.Item>

      <Stack.Item grow>
        <Stack vertical fill>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item width="70%">
                <Section title="MOTHBLOCKS TODO: SPECIES NAME GOES HERE">
                  <Section title="Description">
                    {currentSpecies.description}
                  </Section>

                  <Section title="Features">
                    <SpeciesFeatures features={currentSpecies.features} />
                  </Section>
                </Section>
              </Stack.Item>

              <Stack.Item width="30%">
                <CharacterPreview
                  id={data.character_preview_view}
                  height="100%"
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>

          <Stack.Item>
            <Section title="Lore">
              {currentSpecies.lore}
            </Section>
          </Stack.Item>
        </Stack>
      </Stack.Item>
    </Stack>
  );
};
