import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

const Swarmer: Antagonist = {
  key: "swarmer",
  name: "Swarmer",
  description: [
    multiline`
      A swarmer is a small robot that replicates itself autonomously with
      nearby given materials and prepare structures that they come
      across for the following invasion force.
    `,

    multiline`
      Consume machines, structures, walls, anything to get materials. Replicate
      as many swarmers as you can to repeat the process.
    `,
  ],
  category: Category.Midround,
};

export default Swarmer;
