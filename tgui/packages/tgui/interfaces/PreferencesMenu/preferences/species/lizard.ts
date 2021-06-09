import { Species } from "./base";

const Lizard: Species = {
  description: "The militaristic hail originally from Tizira, but have grown \
    throughout their centuries in the stars to possess a large spacefaring \
    empire: though now they must contend with their younger, more \
    technologically advanced human neighbours.",
  features: {
    good: [],
    neutral: [{
      icon: "thermometer-empty",
      name: "Cold-blooded",
      description: "Higher tolerance for high temperatures, but lower \
        tolerance for cold temperatures.",
    }],
    bad: [{
      icon: "tint",
      name: "Exotic Blood",
      description: "Lizards have a unique \"L\" type blood, which can make \
        receiving medical treatment more difficult.",
    }],
  },
  icon: "wrench",
  lore: "LORE MASTER HELP",
};

export default Lizard;
