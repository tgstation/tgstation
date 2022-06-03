import { Feature, FeatureNumberInput } from "../base";

export const icon_size: Feature<number> = {
  name: "Icon Size",
  category: "UI",
  description: "The icon size of your viewport. Larger values are suitable for larger screens. Too small of numbers may not render correctly",
  component: FeatureNumberInput,
};
