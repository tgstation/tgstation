import { multiline } from "common/string";
import { Feature, FeatureNumberInput } from "../base";

export const loud_sound: Feature<number> = {
  name: "Loud sound volume limit",
  category: "ACCESSIBILITY",
  description: multiline`
    The max volume that can be made from loud machines, like the grav gen.
    Good if you have problems with looping loud sounds.
  `,
  component: FeatureNumberInput,
};
