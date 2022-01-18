import { multiline } from "common/string";
import { CheckboxInput, FeatureToggle } from "../base";

export const loud_sound: FeatureToggle = {
  name: "Disable Loud Sounds",
  category: "ACCESSIBILITY",
  description: multiline`
    When toggled, loud sounds (like the Gravity Generator and Telecomms)
    will be muted. Good if you have problems with looping loud sounds.
  `,
  component: CheckboxInput,
};
