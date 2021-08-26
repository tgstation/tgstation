import { Feature, FeatureDropdownInput } from "../base";

export const pda_style: Feature<string> = {
  name: "PDA style",
  category: "GAMEPLAY",
  description: "The style of your equipped PDA. Changes font.",
  component: FeatureDropdownInput,
};
