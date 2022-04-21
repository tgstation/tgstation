import { CheckboxInput, FeatureToggle } from "../base";

export const buttons_locked: FeatureToggle = {
  name: "Lock action buttons",
  category: "GAMEPLAY",
  description: "When enabled, action buttons will be locked in place.",
  component: CheckboxInput,
};
