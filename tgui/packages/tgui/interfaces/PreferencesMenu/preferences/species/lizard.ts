import { createLanguagePerk, Species } from "./base";

const Lizard: Species = {
  description: "The militaristic hail originally from Tizira, but have grown \
    throughout their centuries in the stars to possess a large spacefaring \
    empire: though now they must contend with their younger, more \
    technologically advanced human neighbours.",
  features: {
    good: [createLanguagePerk("Draconic")],
    neutral: [{
      icon: "thermometer-empty",
      name: "Cold-blooded",
      description: "Higher tolerance for high temperatures, but lower \
        tolerance for cold temperatures.",
    }],
    bad: [{
      icon: "tint",
      name: "Exotic Blood",
      description: "Lizards have a unique \"L\" type blood, which can make \
        receiving medical treatment more difficult.",
    }],
  },
  lore: [
    "The face of conspiracy theory was changed forever the day mankind met the lizards.",
    "Hailing from the arid world of Tizira, lizards were travelling the stars back when mankind was first discovering how neat trains could be. However, much like the space-fable of the space-tortoise and space-hare, lizards have rejected their kin's motto of \"slow and steady\" in favor of resting on their laurels and getting completely surpassed by 'bald apes', due in no small part to their lack of access to plasma.",
    "The history between lizards and humans has resulted in many conflicts that lizards ended on the losing side of, with the finale being an explosive remodeling of their moon. Today's lizard-human relations are seeing the continuance of a record period of peace.",
    "Lizard culture is inherently militaristic, though the influence the military has on lizard culture begins to lessen the further colonies lie from their homeworld - with some distanced colonies finding themselves subsumed by the cultural practices of other species nearby.",
    "On their homeworld, lizards celebrate their 16th birthday by enrolling in a mandatory 5 year military tour of duty. Roles range from combat to civil service and everything in between. As the old slogan goes: \"Your place will be found!\"",
  ],
};

export default Lizard;
