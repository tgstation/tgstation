import { FeatureColorInput, Feature, FeatureDropdownInput } from "../base";

export const asaycolor: Feature<string> = {
  name: "Admin chat color",
  category: "ADMIN",
  description: "The color of your messages in Adminsay.",
  component: FeatureColorInput,
};

export const brief_outfit: Feature<string> = {
  name: "Brief outfit",
  category: "ADMIN",
  description: "The outfit to gain when spawning as the briefing officer.",
  component: FeatureDropdownInput,
};
