import { Feature, FeatureNumberInput } from "../base";

export const fov_darkness: Feature<number> = {
  name: "FoV Darkness",
  category: "GAMEPLAY",
  component: FeatureNumberInput,
};
