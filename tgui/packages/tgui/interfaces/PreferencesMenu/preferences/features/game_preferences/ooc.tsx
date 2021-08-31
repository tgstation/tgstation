import { FeatureColorInput, Feature } from "../base";

export const ooccolor: Feature<string> = {
  name: "OOC color",
  category: "CHAT",
  description: "The color of your OOC messages.",
  component: FeatureColorInput,
};
