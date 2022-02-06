import { createLanguagePerk, Species } from "./base";

const Plasmaman: Species = {
  description: "Found on the Icemoon of Freyja, plasmamen consist of colonial \
    fungal organisms which together form a sentient being. In human space, \
    they're usually attached to skeletons to afford a human touch.",
  features: {
    good: [{
      icon: "shield-alt",
      name: "Protected",
      description: "Plasmamen are immune to radiation, poisons, and most \
        diseases.",
    }, {
      icon: "tint-slash",
      name: "Bloodletted",
      description: "Plasmamen do not have blood.",
    }, {
      icon: "bone",
      name: "Wound Resistance",
      description: "Plasmamen have higher tolerance for damage that would \
        wound others.",
    }, {
      icon: "temperature-low",
      name: "Cold Resistance",
      description: "Plasmamen have a higher resistance to cold temperatures.",
    }, {
      icon: "wind",
      name: "Plasma Healing",
      description: "Plasmamen can heal wounds by consuming plasma.",
    }, {
      icon: "hard-hat",
      name: "Protective Helmet",
      description: "Plasmamen's helmets provide them shielding from the \
        flashes of welding, as well as a flashlight.",
    }, createLanguagePerk("Calcic")],
    neutral: [],
    bad: [{
      icon: "fire",
      name: "Human* Torch",
      description: "Plasmamen instantly ignite when their body makes contact \
        with oxygen.",
    }, {
      icon: "wind",
      name: "Plasma Breathing",
      description: "Plasmamen must breathe plasma to survive. You receive a \
        tank when you arrive.",
    }, {
      icon: "temperature-high",
      name: "Heat Weakness",
      description: "Plasmamen have a lower resistance to high temperatures.",
    }, {
      icon: "fist-raised",
      name: "Total Weakness",
      description: "Plasmamen take more burn and brute damage.",
    }, {
      icon: "briefcase-medical",
      name: "An Apple a Day",
      description: "Plasmamen take specialized medical knowledge to be \
        treated. Do not expect speedy revival, if you are lucky enough to get \
        one at all.",
    }],
  },
  lore: [
    "A confusing species, plasmamen are truly \"a fungus among us\". What appears to be a singular being is actually a colony of millions of organisms surrounding a found (or provided) skeletal structure.",
    "Originally discovered by NT when a researcher fell into an open tank of liquid plasma, the previously unnoticed fungal colony overtook the body creating the first \"true\" plasmaman. The process has since been streamlined via generous donations of convict corpses and plasmamen have been deployed en masse throughout NT to bolster the workforce.",
    "New to the galactic stage, plasmamen are a blank slate. Their appearance, generally regarded as \"ghoulish\", inspires a lot of apprehension in their crewmates. It might be the whole \"flammable purple skeleton\" thing.",
    "The colonids that make up plasmamen require the plasma-rich atmosphere they evolved in. Their psuedo-nervous system runs with externalized electrical impulses that immediately ignite their plasma-based bodies when oxygen is present.",
  ],
};

export default Plasmaman;
