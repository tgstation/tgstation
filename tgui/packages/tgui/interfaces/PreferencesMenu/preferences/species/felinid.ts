import { createLanguagePerk, Species } from "./base";

const Felinid: Species = {
  description: "Felinids are one of the many types of bespoke genetic \
    modifications to come of humanity's mastery of genetic science, and are \
    also one of the most common. Meow?",
  features: {
    good: [{
      icon: "grin-tongue",
      name: "Grooming",
      description: "Felinids can lick wounds to reduce bleeding.",
    }, createLanguagePerk("Nekomimetic")],
    neutral: [],
    bad: [{
      icon: "assistive-listening-systems",
      name: "Sensitive Hearing",
      description: "Felinids are more sensitive to loud sounds, such as \
        flashbangs.",
    }],
  },
  lore: [
    "Bio-engineering at its felinest, felinids are the peak example of humanity's mastery of genetic code. One of many \"animalid\" variants, felinids are the most popular and common, as well as one of the biggest points of contention in genetic-modification.",
    "Body modders were eager to splice human and feline DNA in search of the holy trifecta: ears, eyes, and tail. These traits were in high demand, with the corresponding side effects of vocal and neurochemical changes being seen as a minor inconvenience.",
    "Sadly for the felinids, they were not minor inconveniences. Shunned as subhuman and monstrous by many, felinids (and other animalids) sought their greener pastures out in the colonies, cloistering in communities of their own kind. As a result, outer human space has a high animalid population.",
  ],
};

export default Felinid;
