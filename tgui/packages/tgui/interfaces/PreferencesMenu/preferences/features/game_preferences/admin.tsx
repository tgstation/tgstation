import { FeatureColorInput, Feature } from "../base";

export const asaycolor: Feature<string> = {
  name: "Admin chat color",
  category: "ADMIN",
  description: "The color of your messages in Adminsay.",
  component: FeatureColorInput,
};
