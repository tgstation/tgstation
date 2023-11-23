/// List of areas blacklisted from area based traitor objectives
#define TRAITOR_OBJECTIVE_BLACKLISTED_AREAS list(/area/station/engineering/hallway, \
		/area/station/engineering/lobby, \
		/area/station/engineering/storage, \
		/area/station/science/lobby, \
		/area/station/science/ordnance/bomb, \
		/area/station/science/ordnance/freezerchamber, \
		/area/station/science/ordnance/burnchamber, \
		/area/station/security/prison, \
	)

// Clock cultist
#define IS_CLOCK(mob) ((FACTION_CLOCK in mob.faction) || mob?.mind?.has_antag_datum(/datum/antagonist/clock_cultist))
/// maximum amount of cogscarabs the clock cult can have
#define MAXIMUM_COGSCARABS 9
/// is something a cogscarab
#define iscogscarab(checked) (istype(checked, /mob/living/basic/drone/cogscarab))
/// is something an eminence
#define iseminence(checked) (istype(checked, /mob/living/eminence))
