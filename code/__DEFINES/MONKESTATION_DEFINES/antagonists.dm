// Clock cultist
#define IS_CLOCK(mob) ((FACTION_CLOCK in mob.faction) || mob?.mind?.has_antag_datum(/datum/antagonist/clock_cultist))
