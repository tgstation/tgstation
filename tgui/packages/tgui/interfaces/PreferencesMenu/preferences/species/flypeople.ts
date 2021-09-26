import { createLanguagePerk, Species } from "./base";

const Flypeople: Species = {
  description: "Found on the Icemoon of Freyja, plasmamen consist of colonial \
    fungal organisms which together form a sentient being. In human space, \
    they're usually attached to skeletons to afford a human touch.",
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
      description: "Fly swatters will deal significantly higher ammounts of \
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
    "A confusing species, plasmamen are truly \"a fungus among us\". What appears to be a singular being is actually a colony of millions of organisms surrounding a found (or provided) skeletal structure.",
    "Originally discovered by NT when a researcher fell into an open tank of liquid plasma, the previously unnoticed fungal colony overtook the body creating the first \"true\" plasmaman. The process has since been streamlined via generous donations of convict corpses and plasmamen have been deployed en masse throughout NT to bolster the workforce.",
    "New to the galactic stage, plasmamen are a blank slate. Their appearance, generally regarded as \"ghoulish\", inspires a lot of apprehension in their crewmates. It might be the whole \"flammable purple skeleton\" thing.",
    "The colonids that make up plasmamen require the plasma-rich atmosphere they evolved in. Their psuedo-nervous system runs with externalized electrical impulses that immediately ignite their plasma-based bodies when oxygen is present.",
  ],
};

export default Flypeople;
