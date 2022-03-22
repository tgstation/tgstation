import { multiline } from "common/string";
import { CheckboxInput, Feature, FeatureNumberInput, FeatureToggle } from "../base";

export const enable_tips: FeatureToggle = {
  name: "Enable tooltips",
  category: "TOOLTIPS",
  description: multiline`
    Do you want to see tooltips when hovering over items?
  `,
  component: CheckboxInput,
};

export const tip_delay: Feature<number> = {
  name: "Tooltip delay (in milliseconds)",
  category: "TOOLTIPS",
  description: multiline`
    How long should it take to see a tooltip when hovering over items?
  `,
  component: FeatureNumberInput,
};
