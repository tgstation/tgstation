import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

const Monkey: Antagonist = {
  key: "monkey",
  name: "Monkey",
  description: [
    multiline`
      When the round starts, become infected with Jungle Fever, a disease which
      turns its victim into a monkey. These monkeys can attack humans and give
      them the deadly virus. Turn the entire crew into monkeys!
    `,
  ],
  category: Category.Roundstart,
};

export default Monkey;
