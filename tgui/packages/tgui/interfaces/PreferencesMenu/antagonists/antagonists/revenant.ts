import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

const Revenant: Antagonist = {
  key: "revenant",
  name: "Revenant",
  description: [
    multiline`
      Become the mysterious revenant. Break windows, overload lights, and eat
      the crew's life force, all while talking to your old community of
      disgruntled ghosts.
    `,
  ],
  category: Category.Midround,
};

export default Revenant;
