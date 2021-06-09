import { Species } from "./base";

const Moth: Species = {
  description: "Hailing from a planet that was lost long ago, the moths travel \
    the galaxy as a nomadic people aboard a colossal fleet of ships, seeking a \
    new homeland.",
  features: {
    good: [{
      icon: "feather-alt",
      name: "Precious Wings",
      description: "Moths can fly in pressurized, zero-g environments using \
        their wings.",
    }, {
      icon: "tshirt",
      name: "Meal Plan",
      description: "Moths can eat clothes for nourishment.",
    }],
    neutral: [],
    bad: [{
      icon: "fire",
      name: "Ablazed Wings",
      description: "Moth wings are fragile, and can be easily burnt off.",
    }, {
      icon: "sun",
      name: "Bright Lights",
      description: "Moths need an extra layer of flash protection to protect \
        themselves, such as against security officers or when welding. Welding \
        masks will work.",
    }],
  },
  icon: "wrench",
  lore: "LORE MASTER HELP",
};

export default Moth;
