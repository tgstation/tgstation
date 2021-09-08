import { Antagonist, Category } from "../base";
import { multiline } from "common/string";
import { OPERATIVE_MECHANICAL_DESCRIPTION } from "./operative";

const LoneOperative: Antagonist = {
  key: "loneoperative",
  name: "Lone Operative",
  description: [
    multiline`
      A solo nuclear operative that has a higher chance of spawning the longer
      the nuclear authentication disk stays in one place.
    `,

    OPERATIVE_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default LoneOperative;
