import { Species } from "./base";

const Skeleton: Species = {
  description: "A rattling skeleton! They descend upon Space Station 13 \
    Every year to spook the crew! \"I've got a BONE to pick with you!\"",
  features: {
    good: [{
      icon: "user-plus",
      name: "Limbs Easily Reattached",
      description: "Skeletons limbs are easily readded, and as such do not \
        require surgery to restore. Simply pick it up and pop it back in, \
        champ!",
    }, {
      icon: "skull",
      name: "Undead",
      description: "The undead do not have the need to eat or breathe, and \
        most viruses will not be able to infect a walking corpse. Their \
        worries mostly stop at remaining in one piece, really.",
    }],
    neutral: [],
    bad: [{
      icon: "user-times",
      name: "Limbs Easily Dismembered",
      description: "Skeletons limbs are not secured well, and as such they are \
        easily dismembered.",
    }],
  },
  lore: [
    "Skeletons want to be feared again! Their presence in media has been destroyed, or at least that's what they firmly believe. They're always the first thing fought in an RPG, they're Flanderized into pun rolling JOKES, and it's really starting to get to them. You could say they're deeply RATTLED. Hah.",
  ],
};

export default Skeleton;
