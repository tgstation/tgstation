import { multiline } from "common/string";
import { CheckboxInput, FeatureToggle } from "../base";

export const darkened_flash: FeatureToggle = {
  name: "Enable darkened flashes",
  category: "ACCESSIBILITY",
  description: multiline`
    When toggled, being flashed will show a dark screen rather than a
    bright one. Good if you are easily bothered by bright flashes.
  `,
  component: CheckboxInput,
};
