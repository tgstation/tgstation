import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const TRAITOR_MECHANICAL_DESCRIPTION
   = multiline`
      Start with a set of sinister objectives and an uplink to purchase
      items to get the job done.
   `;

const Traitor: Antagonist = {
  key: "traitor",
  name: "Traitor",
  description: [
    multiline`
      An unpaid debt. A score to be settled. Maybe you were just in the wrong
      place at the wrong time. Whatever the reasons, you were selected to
      infiltrate Space Station 13.
    `,
    TRAITOR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default Traitor;
