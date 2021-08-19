import { createDropdownInput, createNumberInput, Feature } from "./base";

export const age: Feature<number> = {
  name: "Age",
  component: createNumberInput(
    // MOTHBLOCKS TODO: Put MIN_AGE/MAX_AGE on a shared file
    17,
    85,
  ),
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
