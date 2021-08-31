import { FeatureColorInput, Feature, FeatureChoiced, FeatureDropdownInput } from "./base";

export const eye_color: Feature<string> = {
  name: "Eye color",
  component: FeatureColorInput,
};

export const facial_hair_color: Feature<string> = {
  name: "Facial hair color",
  component: FeatureColorInput,
};

export const hair_color: Feature<string> = {
  name: "Hair color",
  component: FeatureColorInput,
};

export const feature_lizard_tail: FeatureChoiced = {
  name: "Tail",
  component: FeatureDropdownInput,
};

export const feature_lizard_spines: FeatureChoiced = {
  name: "Spines",
  component: FeatureDropdownInput,
};

export const feature_mcolor: Feature<string> = {
  name: "Mutant color",
  component: FeatureColorInput,
};
