import { Species } from "./base";

const Plasmaman: Species = {
  description: "Found on the Icemoon of Freyja, plasmamen consist of colonial \
    fungal organisms which together form a sentient being. In human space, \
    they're usually attached to skeletons to afford a human touch.",
  features: {
    good: [{
      icon: "shield-alt",
      name: "Protected",
      description: "Plasmamen are immune to radiation, poisons, and most \
        diseases.",
    }, {
      icon: "tint-slash",
      name: "Bloodletted",
      description: "Plasmamen do not have blood.",
    }, {
      icon: "bone",
      name: "Wound Resistance",
      description: "Plasmamen have higher tolerance for damage that would \
        wound others.",
    }, {
      icon: "temperature-low",
      name: "Cold Resistance",
      description: "Plasmamen have a higher resistance to cold temperatures.",
    }, {
      icon: "wind",
      name: "Plasma Healing",
      description: "Plasmamen can heal wounds by consuming plasma.",
    }, {
      icon: "hard-hat",
      name: "Protective Helmet",
      description: "Plasmamen's helmets provide them shielding from the \
        flashes of welding, as well as a flashlight.",
    }],
    neutral: [],
    bad: [{
      icon: "fire",
      name: "Human* Torch",
      description: "Plasmamen instantly ignite when their body makes contact \
        with oxygen.",
    }, {
      icon: "lungs",
      name: "Plasma Breathing",
      description: "Plasmamen must breathe plasma to survive. You receive a \
        tank when you arrive.",
    }, {
      icon: "temperature-high",
      name: "Heat Weakness",
      description: "Plasmamen have a lower resistance to high temperatures.",
    }, {
      icon: "fist-raised",
      name: "Total Weakness",
      description: "Plasmamen take more burn and brute damage.",
    }, {
      icon: "briefcase-medical",
      name: "An Apple a Day",
      description: "Plasmamen take specialized medical knowledge to be \
        treated. Do not expect speedy revival, if you are lucky enough to get \
        one at all.",
    }],
  },
  lore: "LORE MASTER HELP",
};

export default Plasmaman;
