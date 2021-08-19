import { BooleanLike } from "common/react";
import { createCheckboxInput, createNumberInput, Feature, FeatureToggle } from "../base";

export const enable_tips: FeatureToggle = {
  name: "Enable tooltips",
  category: "TOOLTIPS",
  createComponent: createCheckboxInput(),
};

export const tip_delay: Feature<number> = {
  name: "Tooltip delay (in milliseconds)",
  category: "TOOLTIPS",
  createComponent: createNumberInput(
    // MOTHBLOCKS TODO: Send minimum/maximum through /datum/preference/numeric
    0,
    5000,
  ),
};
