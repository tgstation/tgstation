export type Species = {
  description: string;
  features: {
    good: Feature[],
    neutral: Feature[],
    bad: Feature[],
  };
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

const defaultSpecies: Species = {
  description: "No description! File a bug report!",
  features: {
    good: [],
    neutral: [],
    bad: [],
  },
  lore: "LORE MASTER, I NEED LORE, HELP",
};

export default defaultSpecies;
