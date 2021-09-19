export type Species = {
  description: string;
  features: {
    good: Feature[],
    neutral: Feature[],
    bad: Feature[],
  };
  lore?: string[];
};

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
