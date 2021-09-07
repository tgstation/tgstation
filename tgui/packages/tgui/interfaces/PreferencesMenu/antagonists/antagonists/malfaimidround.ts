import { multiline } from "common/string";
import { Antagonist, Category } from "../base";
import { MALF_AI_MECHANICAL_DESCRIPTION } from "./malfai";

const MalfAIMidround: Antagonist = {
  key: "malfaimidround",
  name: "Value Drifted AI",
  description: [
    multiline`
      A form of malfunctioning AI that is given to existing AIs in the middle
      of the shift.
    `,
    MALF_AI_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
};

export default MalfAIMidround;
