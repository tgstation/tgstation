import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const GANGSTER_MECHANICAL_DESCRIPTION
   = multiline`
      Convince people to join your family, wear your uniform, tag turf
      for the family, and accomplish your family's goals.
   `;

const Gangster: Antagonist = {
  key: "gangster",
  name: "Family Leader",
  description: [
    GANGSTER_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default Gangster;
