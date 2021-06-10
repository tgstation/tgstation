// MOTHBLOCKS TODO: The stupid halloween races

export type Species = {
  description: string;
  features: {
    good: Feature[],
    neutral: Feature[],
    bad: Feature[],
  };
  icon: string; // MOTHBLOCKS TODO: tg svg icons
  lore: string;
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
  icon: "wrench",
  lore: "LORE MASTER, I NEED LORE, HELP",
};
