// Clock cultist
#define IS_CLOCK(mob) ((FACTION_CLOCK in mob.faction) || mob?.mind?.has_antag_datum(/datum/antagonist/clock_cultist))
/// maximum amount of cogscarabs the clock cult can have
#define MAXIMUM_COGSCARABS 9
/// is something a cogscarab
#define iscogscarab(checked) (istype(checked, /mob/living/simple_animal/drone/cogscarab))
/// is something an eminence
#define iseminence(checked) (istype(checked, /mob/living/eminence))
