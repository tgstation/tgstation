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

export const hair_gradient: FeatureChoiced = {
  name: "Hair gradient",
  component: FeatureDropdownInput,
};

export const hair_gradient_color: Feature<string> = {
  name: "Hair gradient color",
  component: FeatureColorInput,
};


export const feature_human_ears: FeatureChoiced = {
  name: "Ears",
  component: FeatureDropdownInput,
};

export const feature_human_tail: FeatureChoiced = {
  name: "Tail",
  component: FeatureDropdownInput,
};

export const feature_lizard_legs: FeatureChoiced = {
  name: "Legs",
  component: FeatureDropdownInput,
};

export const feature_lizard_spines: FeatureChoiced = {
  name: "Spines",
  component: FeatureDropdownInput,
};

export const feature_lizard_tail: FeatureChoiced = {
  name: "Tail",
  component: FeatureDropdownInput,
};

export const feature_mcolor: Feature<string> = {
  name: "Mutant color",
  component: FeatureColorInput,
};

export const underwear_color: Feature<string> = {
  name: "Underwear color",
  component: FeatureColorInput,
};
