import { CheckboxInput, FeatureToggle } from "../base";

export const tgui_fancy: FeatureToggle = {
  name: "Enable fancy tgui",
  category: "UI",
  description: "Makes tgui windows look better, at the cost of compatibility.",
  component: CheckboxInput,
};
