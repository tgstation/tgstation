import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

const Obsessed: Antagonist = {
  key: "obsessed",
  name: "Obsessed",
  description: [
    multiline`
    You're obsessed with someone! Your obsession may begin to notice their
    personal items are stolen and their coworkers have gone missing,
    but will they realize they are your next victim in time?
    `,
  ],
  category: Category.Midround,
};

export default Obsessed;
