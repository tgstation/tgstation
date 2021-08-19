import { BooleanLike } from "common/react";
import { CheckboxInput, Feature, FeatureNumberInput, FeatureToggle } from "../base";

export const enable_tips: FeatureToggle = {
  name: "Enable tooltips",
  category: "TOOLTIPS",
  component: CheckboxInput,
};

export const tip_delay: Feature<number> = {
  name: "Tooltip delay (in milliseconds)",
  category: "TOOLTIPS",
  component: FeatureNumberInput,
};
