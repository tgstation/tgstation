/// List of antagonists that can be considered prey by monster hunters.
GLOBAL_LIST_INIT(monster_hunter_prey_antags, typecacheof(list(
	/datum/antagonist/bloodsucker,
	/datum/antagonist/changeling,
	/datum/antagonist/heretic
)))

/proc/is_monster_hunter_prey(datum/mind/victim)
	. = FALSE
	if(isliving(victim))
		var/mob/living/living_victim = victim
		victim = living_victim.mind
	if(!istype(victim) || QDELING(victim))
		return FALSE
	for(var/datum/antagonist/antag as anything in victim.antag_datums)
		if(is_type_in_typecache(antag, GLOB.monster_hunter_prey_antags))
			return TRUE

/proc/get_all_monster_hunter_prey(include_dead = FALSE)
	. = list()
	for(var/datum/antagonist/monster as anything in GLOB.antagonists)
		if(QDELETED(monster?.owner?.current) || (!include_dead && monster.owner.current.stat == DEAD))
			continue
		if(is_type_in_typecache(monster, GLOB.monster_hunter_prey_antags))
			. += monster.owner
