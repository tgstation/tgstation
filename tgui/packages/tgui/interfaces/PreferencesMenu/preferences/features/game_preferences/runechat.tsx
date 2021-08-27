import { CheckboxInput, FeatureToggle } from "../base";

export const chat_on_map: FeatureToggle = {
  name: "Enable Runechat",
  category: "GAMEPLAY",
  description: "Chat messages will show above heads.",
  component: CheckboxInput,
};

export const see_chat_non_mob: FeatureToggle = {
  name: "Enable Runechat on objects",
  category: "GAMEPLAY",
  description: "Chat messages will show above objects when they speak.",
  component: CheckboxInput,
};

export const see_rc_emotes: FeatureToggle = {
  name: "Enable Runechat emotes",
  category: "GAMEPLAY",
  description: "Emotes will show above heads.",
  component: CheckboxInput,
};
