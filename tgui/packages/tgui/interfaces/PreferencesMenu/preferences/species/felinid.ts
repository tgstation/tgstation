import { Species } from "./base";

const Felinid: Species = {
  description: "Felinids are one of the many types of bespoke genetic \
    modifications to come of humanity's mastery of genetic science, and are \
    also one of the most common. Meow?",
  features: {
    good: [{
      icon: "grin-tongue",
      name: "Grooming",
      description: "Felinids can lick wounds to reduce bleeding.",
    }],
    neutral: [],
    bad: [{
      icon: "assistive-listening-systems",
      name: "Sensitive Hearing",
      description: "Felinids are more sensitive to loud sounds, such as \
        flashbangs.",
    }],
  },
  lore: "LORE MASTER HELP",
};

export default Felinid;
