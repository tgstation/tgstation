import { createLanguagePerk, Species } from "./base";

const Fly: Species = {
  description: "With no official documentation or knowledge of the origin of \
    this species, they remain a mystery to most. Any and all rumours among \
    Nanotrasen staff regarding flypeople are often quickly silenced by high \
    ranking staff or officials.",
  features: {
    good: [{
      icon: "grin-tongue",
      name: "Uncanny Digestive System",
      description: "Flypeople regurgitate their stomach contents and drink it \
        off the floor to eat and drink with little care for taste, favoring \
        gross foods.",
    }, createLanguagePerk("Buzzwords")],
    neutral: [],
    bad: [{
      icon: "fist-raised",
      name: "Insectoid Biology",
      description: "Fly swatters will deal significantly higher amounts of \
      damage to a Flyperson.",
    }, {
      icon: "sun",
      name: "Radial eyesight",
      description: "Flypeople can be flashed from all angles.",
    }, {
      icon: "briefcase-medical",
      name: "Weird Organs",
      description: "Flypeople take specialized medical knowledge to be \
        treated. Their organs are disfigured and organ manipulation can \
        be interesting...",
    }],
  },
  lore: [
    "Flypeople are a curious species with a striking resemblance to the insect order of Diptera, commonly known as flies. With no publically known origin, flypeople are rumored to be a side effect of bluespace travel, despite statements from Nanotrasen officials.",
    "Little is known about the origins of this race, however they posess the ability to communicate with giant spiders, originally discovered in the Australicus sector and now a common occurence in black markets as a result of a breakthrough in syndicate bioweapon research.",
    "Flypeople are often feared or avoided among other species, their appearance often described as unclean or frightening in some cases, and their eating habits even more so with an insufferable accent to top it off.",
  ],
};

export default Fly;
