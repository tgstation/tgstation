import { multiline } from "common/string";
import { FeatureChoiced, FeatureDropdownInput } from "../base";

export const ghost_accs: FeatureChoiced = {
  name: "Ghost accessories",
  category: "GHOST",
  description: "Determines how your ghost will look.",
  component: FeatureDropdownInput,
};

export const ghost_orbit: FeatureChoiced = {
  name: "Ghost orbit",
  category: "GHOST",
  description: "The shape in which your ghost will orbit.",
  component: FeatureDropdownInput,
};

export const ghost_others: FeatureChoiced = {
  name: "Ghosts of others",
  category: "GHOST",
  description: multiline`
    Do you want the ghosts of others to show up as their own setting, as
    their default sprites, or always as the default white ghost?
  `,
  component: FeatureDropdownInput,
};
