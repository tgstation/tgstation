import { Feature, FeatureNumberInput, FeatureShortTextInput, FeatureTextInput } from '../base';

export const age_chronological: Feature<string> = {
  name: 'Age (Chronological)',
  description: "The actual, physical age of your character. Applicable mostly in instances of prolonged cryogenic stasis or for lifeforms that mature or metabolize at much slower rates compared to 'standard' sector races.",
  component: FeatureNumberInput,
};

export const flavor_short_desc: Feature<string> = {
  name: 'Short description',
  description:
    "Appears when shift-clicked or otherwise looked at, when not disguised. A one to three sentence blurb that describes the major features of your character at a glance, such as gender, race, height, etc. Example: 'Standing at five and a half feet tall, this brown-skinned, grizzled human male is a distinct rarity out in this part of the galaxy.'",
  component: FeatureTextInput,
};

export const flavor_extended_desc: Feature<string> = {
  name: 'Long description',
  description:
    "Appears when examined further. A lengthy description of your character written as descriptive prose, up to 4096 characters in total length. Your <i>short description</i> will always be shown as your first paragraph, so you don't need to duplicate it again here. ",
  component: FeatureTextInput,
};

export const custom_species_name: Feature<string> = {
  name: "Species name",
  description: "Appears when looked at. Leave blank to match a default coded race (such as Human).",
  component: FeatureShortTextInput,
};

export const custom_species_desc: Feature<string> = {
  name: "Species description",
  description: "Appears when examined further. An overview of your species, ideally limited to commonly-known facts such as general physical appearances, origin world/sector, and so on. This should not be excessively long - you're better off sharing that information via IC interactions (or records) instead of expecting people to read it off your examine.",
  component: FeatureTextInput,
};
