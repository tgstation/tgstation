import { Species } from "./base";

const Dullahan: Species = {
  description: "An angry spirit, hanging onto the land of the living for \
    unfinished business. Or that's what the books say. They're quite nice \
    when you get to know them.",
  features: {
    good: [{
      icon: "skull",
      name: "Minor Undead",
      description: "Minor undead enjoy some of the perks of being dead, like \
        not needing to breathe or eat, but do not get many of the \
        environmental immunities involved with being fully undead.",
    }],
    neutral: [],
    bad: [{
      icon: "horse-head",
      name: "Headless and Horseless",
      description: "Dullahans must lug their head around in their arms. While \
      many creative uses can come out of your head being independent of your \
      body, Dullahans will find it mostly a pain.",
    }],
  },
  lore: [
    "\"No wonder they're all so grumpy! Their hands are always full! I used to think, \"Wouldn't this be cool?\" but after watching these creatures suffer from their head getting dunked down disposals for the nth time, I think I'm good.\" - Captain Larry Dodd",
  ],
};

export default Dullahan;
