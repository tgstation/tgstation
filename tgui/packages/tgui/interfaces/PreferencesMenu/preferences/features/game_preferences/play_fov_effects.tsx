import { multiline } from "common/string";
import { CheckboxInput, FeatureToggle } from "../base";

export const play_fov_effects: FeatureToggle = {
  name: "Enable blindness effects",
  category: "GAMEPLAY",
  description: multiline`
    When toggled, sounds will create visual effects 
    if your character doesn't see where it's coming from.
  `,
  component: CheckboxInput,
};
