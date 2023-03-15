import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const DARKSPAWN_MECHANICAL_DESCRIPTION
   = multiline`
      Finish what you and your fellow kin started eons ago.
      Ascend to godhood with two others by harvesting the sparks of the infirm.
      The sigils hunger, and you must respond.
   `;


const Darkspawn: Antagonist = {
  key: "darkspawn",
  name: "Darkspawn",
  description: [
    multiline`
      It’s hard to recall what you once were. Star cycles passed again and again as you slumbered in the Void.
      Eventually, the emptiness touched something.
      You fabricated a shoddy disguise from your first victim, and now countless minds tug at your attention.
    `,
    DARKSPAWN_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Darkspawn;
