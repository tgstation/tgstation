import { Antagonist, Category } from "../base";
import { multiline } from "common/string";

export const RATVAR_MECHANICAL_DESCRIPTION
   = multiline`
      Teleport onto the Nanotrasen station and subvert its power and its people to your own. \
      Once the Ark is ready, defend it from the crew's assault. Purge all untruths and honor Ratvar.
   `;

const ServantOfRatvar: Antagonist = {
  key: "servantofratvar",
  name: "Servant of Ratvar",
  description: [
    multiline`
      A flash of yellow light! The sound of whooshing steam and clanking cogs surrounds you, and you understand your mission.
      Ratvar, the Clockwork Justicar, has trusted you to secure the gateway in his Ark!
    `,
    RATVAR_MECHANICAL_DESCRIPTION,
  ],
  category: Category.Roundstart,
  priority: -1,
};

export default ServantOfRatvar;
