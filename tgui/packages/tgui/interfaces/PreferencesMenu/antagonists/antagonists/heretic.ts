import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const HERETIC_MECHANICAL_DESCRIPTION
   = multiline`
      Find hidden influences and sacrifice crew members to gain magical
      powers and ascend as one of several paths.
   `;

const Heretic: Antagonist = {
  key: "heretic",
  name: "Heretic",
  description: [
    multiline`
      Forgotten, devoured, gutted. Humanity has forgotten the eldritch forces
      of decay, but the mansus veil has weakened. We will make them taste fear
      again...
    `,
    HERETIC_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Heretic;
