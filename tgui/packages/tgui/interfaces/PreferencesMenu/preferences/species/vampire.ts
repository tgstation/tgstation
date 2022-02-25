import { Species } from "./base";

const Vampire: Species = {
  description: "A classy Vampire! They descend upon Space Station Thirteen \
    Every year to spook the crew! \"Bleeg!!\"",
  features: {
    good: [{
      icon: "bed",
      name: "Coffin Brooding",
      description: "Vampires can delay The Thirst and heal by resting in a \
        coffin. So THAT'S why they do that!",
    }, {
      icon: "skull",
      name: "Minor Undead",
      description: "Minor undead enjoy some of the perks of being dead, like \
        not needing to breathe or eat, but do not get many of the \
        environmental immunities involved with being fully undead.",
    }],
    neutral: [],
    bad: [{
      icon: "tint",
      name: "The Thirst",
      description: "In place of eating, vampires suffer from The Thirst. \
      Thirst of what? Blood! Their tongue allows them to grab people and drink \
      their blood, and they will die if they run out. As a note, it doesn't \
      matter whose blood you drink, it will all be converted into your blood \
      type when consumed.",
    },
    {
      icon: "cross",
      name: "Against God and Nature",
      description: "Almost all higher powers are disgusted by the existence of \
      vampires, and entering the chapel is essentially suicide. Do not do it!",
    }],
  },
  lore: [
    "Vampires are unholy beings blessed and cursed with The Thirst. The Thirst requires them to feast on blood to stay alive, and in return it gives them many bonuses. Because of this, Vampires have split into two clans, one that embraces their powers as a blessing and one that rejects it.",
  ],
};

export default Vampire;
