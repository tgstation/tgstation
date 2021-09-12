import { InfernoNode } from "inferno";

// MOTHBLOCKS TODO: The stupid halloween races
export type Species = {
  description: string;
  features: {
    good: Feature[],
    neutral: Feature[],
    bad: Feature[],
  };
  lore?: string[];
};

// MOTHBLOCKS TODO: What if the features were config-dependent?
// As in, you don't see humans can be command if the config says that
// isn't true.
// Could add a feature flag.
export type Feature = {
  icon: string;
  name: string;
  description: string;
};

export const fallbackSpecies: Species = {
  description: "No description! File a bug report!",
  features: {
    good: [],
    neutral: [],
    bad: [],
  },
};

export const createLanguagePerk = (language: string): Feature => {
  return {
    icon: "comment",
    name: "Native Speaker",
    description:
      `Alongside Galactic Common, gain the ability to speak ${language}.`,
  };
};
