import { createLanguagePerk, Species } from "./base";

const Moth: Species = {
  description: "Hailing from a planet that was lost long ago, the moths travel \
    the galaxy as a nomadic people aboard a colossal fleet of ships, seeking a \
    new homeland.",
  features: {
    good: [{
      icon: "feather-alt",
      name: "Precious Wings",
      description: "Moths can fly in pressurized, zero-g environments and \
        safely land short falls using their wings.",
    }, {
      icon: "tshirt",
      name: "Meal Plan",
      description: "Moths can eat clothes for nourishment.",
    }, createLanguagePerk("Moffic")],
    neutral: [],
    bad: [{
      icon: "fire",
      name: "Ablazed Wings",
      description: "Moth wings are fragile, and can be easily burnt off.",
    }, {
      icon: "sun",
      name: "Bright Lights",
      description: "Moths need an extra layer of flash protection to protect \
        themselves, such as against security officers or when welding. Welding \
        masks will work.",
    }],
  },
  lore: [
    "Their homeworld lost to the ages, the moths live aboard the Grand Nomad Fleet. Made up of what could be found, bartered, repaired, or stolen the armada is a colossal patchwork built on a history of politely flagging travelers down and taking their things. Occasionally a moth will decide to leave the fleet, usually to strike out for fortunes to send back home.",
    "Nomadic life produces a tight-knit culture, with moths valuing their friends, family, and vessels highly. Moths are gregarious by nature and do best in communal spaces. This has served them well on the galactic stage, maintaining a friendly and personable reputation even in the face of hostile encounters. It seems that the galaxy has come to accept these former pirates.",
    "Surprisingly, living together in a giant fleet hasn't flattened variance in dialect and culture. These differences are welcomed and encouraged within the fleet for the variety that they bring.",
  ],
};

export default Moth;
