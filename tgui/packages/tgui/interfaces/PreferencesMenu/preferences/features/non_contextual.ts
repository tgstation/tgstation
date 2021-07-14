import { Feature, ValueType } from "./base";

export const age: Feature = {
  name: "Age",

  valueType: ValueType.Number,

  // MOTHBLOCKS TODO: Put MIN_AGE/MAX_AGE on a shared file
  minimum: 17,
  maximum: 85,
};
