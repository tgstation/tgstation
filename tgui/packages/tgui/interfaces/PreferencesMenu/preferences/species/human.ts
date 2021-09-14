import { Species } from "./base";

const Human: Species = {
  description: "Humans are the dominant species in the known galaxy, their \
    kind extend from old Earth to the edges of known space.",
  features: {
    good: [{
      icon: "robot",
      name: "Asimov Superiority",
      description: "The AI and their cyborgs are, by default, subservient only \
        to humans. As a human, silicons are required to both protect and obey \
        you.",
    }, {
      icon: "bullhorn",
      name: "Chain of Command",
      description: "Nanotrasen only recognizes humans for command roles, such \
        as Captain.",
    }],
    neutral: [],
    bad: [],
  },
  lore: [
    "These primate-descended creatures, originating from the mostly harmless Earth, have long-since outgrown their home and semi-benign designation. The space age has taken humans out of their solar system and into the galaxy-at-large.",
    "In traditional human fashion, this near-record pace from terra firma to the final frontier spat in the face of other races they now shared a stage with. This included the lizards - if anyone was offended by these upstarts, it was certainly lizardkind.",
    "Humanity never managed to find the kind of peace to fully unite under one banner like other species. The pencil and paper pushing of the UN bureaucrat lives on in the mosaic that is TerraGov; a composite of the nation-states that still live on in human society.",
    "The human spirit of opportunity and enterprise continues on in its peak form: the hypercorporation. Acting outside of TerraGov's influence, literally and figuratively, hypercorporations buy the senate votes they need and establish territory far past the Earth Government's reach. In hypercorporation territory company policy is law, giving new meaning to \"employee termination\".",
  ],
};

export default Human;
