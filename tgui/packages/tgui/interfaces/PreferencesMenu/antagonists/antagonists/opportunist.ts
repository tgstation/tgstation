import { multiline } from "common/string";
import { Antagonist, Category } from "../base";
import { THIEF_MECHANICAL_DESCRIPTION } from "./thief";

const Opportunist: Antagonist = {
  key: "opportunist",
  name: "Opportunist",
  description: [
    multiline`Something's going down, it's all about to be FUBAR. Maybe
    nobody will notice if you supplement your paycheck with some loot?`,
    THIEF_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default Opportunist;
