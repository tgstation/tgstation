import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const THIEF_MECHANICAL_DESCRIPTION
  = multiline`
      While all the chaos of the station goes down, try to escape with
      some loot without getting caught!
    `;

const Thief: Antagonist = {
  key: "thief",
  name: "Thief",
  description: [
    `You're working at a state of the art research station, yet you're
    running into financial issues. Nobody will miss a couple expensive doodads,
    right?`,
    THIEF_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Thief;
