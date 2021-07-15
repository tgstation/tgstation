import { Feature, ValueType } from "./base";

export const age: Feature = {
  name: "Age",

  valueType: ValueType.Number,

  // MOTHBLOCKS TODO: Put MIN_AGE/MAX_AGE on a shared file
  minimum: 17,
  maximum: 85,
};

export const uplink_loc: Feature = {
  name: "Uplink Spawn Location",

  valueType: ValueType.Choiced,

  choices: {
    // MOTHBLOCKS TODO: UPLINK_IMPLANT_TELECRYSTAL_COST
    Implant: "Implant (-4TC)",
    PDA: "PDA",
    Pen: "Pen",
    Radio: "Radio",
  },
};
