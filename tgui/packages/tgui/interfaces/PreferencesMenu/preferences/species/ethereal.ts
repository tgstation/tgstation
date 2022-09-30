import { createLanguagePerk, Species } from "./base";

const Ethereal: Species = {
  description: "Coming from the planet of Sprout, the theocratic ethereals are \
    separated socially by caste, and espouse a dogma of aiding the weak and \
    downtrodden.",
  features: {
    good: [{
      icon: "bolt",
      name: "Shockingly Tasty",
      description: "Ethereals can feed on electricity from APCs, and do not \
        otherwise need to eat.",
    }, {
      icon: "lightbulb",
      name: "Disco Ball",
      description: "Ethereals passively generate their own light.",
    }, {
      icon: "shield-alt",
      name: "Shock Resistance",
      description: "Ethereals are less affected by shocks.",
    }, {
      icon: "temperature-high",
      name: "Heat Resistance",
      description: "Ethereals have much better tolerance for high \
        temperatures.",
    }, createLanguagePerk("Voltaic")],
    neutral: [{
      icon: "tint",
      name: "Liquid Electricity",
      description: "Ethereals have liquid electricity instead of blood. \
        Great for them, horrid for anyone else. Can make receiving medical \
        treatment harder.",
    }, {
      icon: "fire",
      name: "Flaming Punch",
      description: "Ethereals deal burn damage when punching instead of \
        brute damage.",
    }, {
      icon: "gem",
      name: "Crystal Core",
      description: "The hearts of ethereals will protect them in a cystal when \
        they die, reviving them with a permanent brain trauma.",
    }],
    bad: [{
      icon: "biohazard",
      name: "Starving Artist",
      description: "Ethereals take toxin damage while starving.",
    }, {
      icon: "fist-raised",
      name: "Brutal Weakness",
      description: "Ethereals are weak to brute damage.",
    }, {
      icon: "temperature-low",
      name: "Cold Weakness",
      description: "Ethereals have much lower tolerance for cold \
        temperatures.",
    }],
  },
  lore: [
    "Ethereals are a species native to the planet Sprout. When they were originally discovered, they were at a medieval level of technological progression, but due to their natural acclimation with electricity, they felt easy among the large NanoTrasen installations.",
  ],
};

export default Ethereal;
