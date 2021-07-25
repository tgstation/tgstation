import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

const Wizard: Antagonist = {
  key: "wizard",
  name: "Wizard",
  description: [
    `"GREETINGS. WE'RE THE WIZARDS OF THE WIZARD'S FEDERATION."`,

    multiline`
      Choose between a variety of powerful spells in order to cause chaos
      among Space Station 13.
    `,
  ],
  category: Category.Roundstart,
};

export default Wizard;
