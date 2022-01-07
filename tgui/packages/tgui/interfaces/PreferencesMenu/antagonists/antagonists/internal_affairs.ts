import { Antagonist, Category } from "../base";
import { multiline } from "common/string";
import { TRAITOR_MECHANICAL_DESCRIPTION } from "./traitor";

const InternalAffairsAgent: Antagonist = {
  key: "internalaffairsagent",
  name: "Internal Affairs Agent",
  description: [
    multiline`
      Sent by either Nanotrasen or the Syndicate, find and kill your target,
      but watch your back, as someone is hunting you too.
    `,

    TRAITOR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
};

export default InternalAffairsAgent;
