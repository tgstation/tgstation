import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

const SpaceDragon: Antagonist = {
  key: "spacedragon",
  name: "Space Dragon",
  description: [
    multiline`
      Become a ferocious space dragon. Breathe fire, summon an army of space
      carps, crush walls, and terrorize the station.
    `,
  ],
  category: Category.Midround,
};

export default SpaceDragon;
