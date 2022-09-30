import { CheckboxInput, FeatureToggle } from "../base";

export const tgui_fancy: FeatureToggle = {
  name: "Enable fancy tgui",
  category: "UI",
  description: "Makes tgui windows look better, at the cost of compatibility.",
  component: CheckboxInput,
};

export const tgui_lock: FeatureToggle = {
  name: "Lock tgui to main monitor",
  category: "UI",
  description: "Locks tgui windows to your main monitor.",
  component: CheckboxInput,
};
