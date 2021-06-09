import { Species } from "./base";

const Human: Species = {
  description: "Humans are the dominant species in the known galaxy, their \
    kind extend from old Earth to the edges of known space.",
  features: {
    good: [{
      icon: "robot",
      name: "Asimov Superiority",
      description: "The AI and their cyborgs are, by default, subservient only \
        to humans. As a human, silicons are required to both protect and obey \
        you.",
    }, {
      icon: "bullhorn",
      name: "Chain of Command",
      description: "NanoTrasen only recognizes humans for command roles, such \
        as Captain.",
    }],
    neutral: [],
    bad: [],
  },
  icon: "wrench",
  lore: "LORE MASTER HELP",
};

export default Human;
