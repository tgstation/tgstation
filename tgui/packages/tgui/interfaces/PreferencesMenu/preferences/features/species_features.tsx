import { createColorInput, Feature } from "./base";

export const eye_color: Feature<string> = {
  name: "Eye color",
  createComponent: createColorInput,
};

export const facial_hair_color: Feature<string> = {
  name: "Facial hair color",
  createComponent: createColorInput,
};

export const hair_color: Feature<string> = {
  name: "Hair color",
  createComponent: createColorInput,
};
