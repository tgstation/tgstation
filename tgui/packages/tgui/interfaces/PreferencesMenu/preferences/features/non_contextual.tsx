import { createDropdownInput, Feature, FeatureNumberInput } from "./base";

export const age: Feature<number> = {
  name: "Age",
  component: FeatureNumberInput,
};

export const uplink_loc: Feature<string> = {
  name: "Uplink Spawn Location",
  component: createDropdownInput({
    // MOTHBLOCKS TODO: UPLINK_IMPLANT_TELECRYSTAL_COST
    Implant: "Implant (-4TC)",
    PDA: "PDA",
    Pen: "Pen",
    Radio: "Radio",
  }),
};
