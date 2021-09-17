import { Antagonist, Category } from "../base";
import { TRAITOR_MECHANICAL_DESCRIPTION } from "./traitor";
import { multiline } from "common/string";

const SyndicateSleeperAgent: Antagonist = {
  key: "syndicatesleeperagent",
  name: "Syndicate Sleeper Agent",
  description: [
    multiline`
      A form of traitor that can activate at any point in the middle
      of the shift.
    `,
    TRAITOR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Midround,
  priority: -1,
};

export default SyndicateSleeperAgent;
