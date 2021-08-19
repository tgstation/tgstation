import { BooleanLike } from "common/react";
import { CheckboxInput, createNumberInput, Feature, FeatureToggle } from "../base";

export const enable_tips: FeatureToggle = {
  name: "Enable tooltips",
  category: "TOOLTIPS",
  component: CheckboxInput,
};

export const tip_delay: Feature<number> = {
  name: "Tooltip delay (in milliseconds)",
  category: "TOOLTIPS",
  component: createNumberInput(
    // MOTHBLOCKS TODO: Send minimum/maximum through /datum/preference/numeric
    0,
    5000,
  ),
};
