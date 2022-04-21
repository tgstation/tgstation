import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

const Xenomorph: Antagonist = {
  key: "xenomorph",
  name: "Xenomorph",
  description: [
    multiline`
      Become the extraterrestrial xenomorph. Start as a larva, and progress
      your way up the caste, including even the Queen!
    `,
  ],
  category: Category.Midround,
};

export default Xenomorph;
