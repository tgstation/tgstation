import { multiline } from "common/string";
import { createDropdownInput, Feature, FeatureChoiced, FeatureDropdownInput } from "../base";

export const ghost_orbit: FeatureChoiced = {
  name: "Ghost orbit",
  category: "GHOST",
  description: "The shape in which your ghost will orbit.",
  component: FeatureDropdownInput,
};

export const ghost_others: Feature<number> = {
  name: "Ghosts of others",
  category: "GHOST",
  description: multiline`
    Do you want the ghosts of others to show up as their own setting, as
    their default sprites, or always as the default white ghost?
  `,
  // FUCK whoever made these 1/50/100, unbelievable
  component: createDropdownInput({
    1: "White ghosts",
    50: "Default sprites",
    100: "Their sprites",
  }),
};
