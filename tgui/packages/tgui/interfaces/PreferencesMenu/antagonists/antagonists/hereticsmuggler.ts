import { Antagonist, Category } from "../base";
import { HERETIC_MECHANICAL_DESCRIPTION } from "./heretic";

const HereticSmuggler: Antagonist = {
  key: "hereticsmuggler",
  name: "Heretic Smuggler",
  description: [
    "A form of heretic that can activate when joining an ongoing shift.",
    HERETIC_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Latejoin,
};

export default HereticSmuggler;
