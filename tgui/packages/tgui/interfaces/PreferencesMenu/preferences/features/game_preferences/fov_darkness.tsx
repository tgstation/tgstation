import { Feature, FeatureNumberInput } from "../base";

export const fov_darkness: Feature<number> = {
  name: "Field of view darkness",
  category: "GAMEPLAY",
  description: "The density of darkness of field of vision cones you may have by wearing restrictive eye cover.",
  component: FeatureNumberInput,
};
