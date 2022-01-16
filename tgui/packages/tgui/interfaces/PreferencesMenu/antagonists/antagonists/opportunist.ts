import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const THIEF_MECHANICAL_DESCRIPTION
  = multiline`
      While all the chaos of the station goes down, try to escape with
      some loot without getting caught!
    `;

const Opportunist: Antagonist = {
  key: "opportunist",
  name: "Opportunist",
  description: [
    `Something's going down, it's all about to be FUBAR. Maybe nobody will
    notice if you nick some loot in the chaos?`,
    THIEF_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default Opportunist;
