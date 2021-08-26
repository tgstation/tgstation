import { multiline } from "common/string";
import { FeatureColorInput, Feature } from "../base";

export const ooccolor: Feature<string> = {
  name: "OOC color",
  category: "ADMIN",
  description: "The color of your OOC messages while adminned.",
  component: FeatureColorInput,
};
