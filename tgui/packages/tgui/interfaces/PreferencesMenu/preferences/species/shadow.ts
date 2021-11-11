import { Species } from "./base";

const Shadowperson: Species = {
  description: "Victims of a long extinct space alien. Their flesh is a sickly \
    seethrough filament, their tangled insides in clear view. Their form \
    is a mockery of life, leaving them mostly unable to work with others under \
    normal circumstances.",
  features: {
    good: [{
      icon: "moon",
      name: "Shadowborn",
      description: "Their skin blooms in the darkness. All kinds of damage, \
      no matter how extreme, will heal over time as long as there is no light.",
    }, {
      icon: "eye",
      name: "Nightvision",
      description: "Their eyes, adapted to the night, Can \
      see in the dark with no problems.",
    }],
    neutral: [],
    bad: [{
      icon: "sun",
      name: "Lightburn",
      description: "Their skin withers in the light. Any exposure to light is \
      incredibly painful for the shadowperson, charring their skin.",
    }],
  },
  lore: [
    "Long ago, the Spinward Sector used to be inhabited by terrifying aliens aptly named \"Shadowlings\" after their control over darkness, and tendancy to kidnap victims into the dark maintenance shafts. Around 2558, the long campaign Nanotrasen waged against the space terrors ended with the full extinction of the Shadowlings.",
    "Victims of their kidnappings would become brainless thralls, and via surgery they could be freed from the Shadowling's control. Those more unlucky would have their entire body transformed by the Shadowlings to better serve in kidnappings. Unlike the brain tumors of lesser control, these greater thralls could not be reverted.",
    "With Shadowlings long gone, their will is their own again. But their bodies have not reverted, burning in exposure to light. Nanotrasen has assured the victims that they are searching for a cure. No further information has been given, even years later. Most shadowpeople now assume Nanotrasen has long since shelfed the project.",
  ],
};

export default Shadowperson;
