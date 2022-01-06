import { Species } from "./base";

const Mummy: Species = {
  description: "A wrapped up mummy! They descend upon Space Station Thirteen \
    Every year to spook the crew! \"Return the slab!\"",
  features: {
    good: [{
      icon: "recycle",
      name: "Reformation",
      description: "A boon quite similar to Ethereals, Mummies collapse into \
      a pile of bandages after they die. If left alone, they will reform back \
      into themselves. The bandages themselves are very vulnerable to fire.",
    }, {
      icon: "gem",
      name: "Lithoid",
      description: "Lithoids are creatures made out of elements instead of \
        blood and flesh. Because of this, they're generally stronger, slower, \
        and mostly immune to environmental dangers and complicated medical \
        problems like viruses and dismemberment.",
    }],
    neutral: [],
    bad: [{
      icon: "fire-alt",
      name: "Incredibly Flammable",
      description: "Mummies are made entirely of cloth, which makes them \
        very vulnerable to fire. They will not reform if they die while on \
        fire, and they will easily catch alight.",
    }],
  },
  lore: [
    "Mummies are very self conscious. They're shaped weird, they walk slow, and worst of all, they're considered the laziest halloween costume. But that's not even true, they say.",
    "Making a mummy costume may be easy, but making a CONVINCING mummy costume requires things like proper fabric and purposeful staining to achieve the look. Which is FAR from easy. Gosh.",
  ],
};

export default Mummy;
