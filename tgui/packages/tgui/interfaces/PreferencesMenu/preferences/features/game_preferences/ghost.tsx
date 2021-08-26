import { multiline } from "common/string";
import { createDropdownInput, Feature, FeatureChoiced, FeatureDropdownInput } from "../base";

export const ghost_accs: Feature<number> = {
  name: "Ghost accessories",
  category: "GHOST",
  description: "Determines how your ghost will look.",

  // FUCK whoever made these 1/50/100, unbelievable.
  // Can't even make it an assoc list because of it.
  component: createDropdownInput({
    1: "Default sprites",
    50: "Only directional sprites",
    100: "Full accessories",
  }),
};

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
  component: createDropdownInput({
    1: "White ghosts",
    50: "Default sprites",
    100: "Their sprites",
  }),
};
