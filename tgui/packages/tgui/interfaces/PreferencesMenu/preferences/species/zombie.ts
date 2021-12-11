import { Species } from "./base";

const Zombie: Species = {
  description: "A rotting zombie! They descend upon Space Station Thirteen \
    Every year to spook the crew! \"Sincerely, the Zombies!\"",
  features: {
    good: [{
      icon: "user-plus",
      name: "Limbs Easily Reattached",
      description: "A zombie's limbs are easily readded, and as such do not \
        require surgery to restore. Simply pick it up and pop it back in, \
        champ!",
    }, {
      icon: "skull",
      name: "Undead",
      description: "The undead do not have the need to eat or breathe, and \
        most viruses will not be able to infect a walking corpse. Their \
        worries mostly stop at remaining in one piece, really.",
    }],
    neutral: [{
      icon: "thermometer-half",
      name: "No Body Temperature",
      description: "Having long since departed, zombies do not have anything \
        regulating their body temperature anymore. This simply means that \
        their environment decides their temperature, which they don't mind at \
        all until it gets a bit too hot.",
    }],
    bad: [{
      icon: "user-times",
      name: "Limbs Easily Dismembered",
      description: "A zombie's limbs are not secured well, and as such they are \
        easily dismembered.",
    }, {
      icon: "user-injured",
      name: "Easily Wounded",
      description: "Zombies are always in a state of falling apart. They are \
        much easier to apply serious wounds to.",
    }],
  },
  lore: [
    "Zombies have long lasting beef with Botanists. Their last incident involving a lawn with defensive plants has left them very unhinged.",
  ],
};

export default Zombie;
