/datum/dynamic_ruleset/midround/from_ghosts/loneops
	name = "Lone Operative"
	antag_flag = ROLE_OPERATIVE
	antag_datum = /datum/antagonist/nukeop/lone
	enemy_roles = list("AI", "Cyborg", "Security Officer", "Warden","Detective","Head of Security", "Captain")
	required_enemies = list(1,1,1,1,0,0,0,0,0,0) 
	required_candidates = 1
	weight = 1
	cost = 15
	requirements = list(50,40,30,20,10,10,10,10,10,10)
	high_population_requirement = 10

/datum/dynamic_ruleset/midround/from_ghosts/loneops/acceptable(population=0, threat=0)
	if (locate(/datum/dynamic_ruleset/roundstart/nuclear) in mode.executed_rules)
		return FALSE // Unavailable if nuke ops were already sent at roundstart
	return ..()

/datum/dynamic_ruleset/midround/from_ghosts/loneops/finish_setup(mob/new_character, index)
	new_character.mind.assigned_role = "Lone Operative"
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
		spawn_locs += L.loc
	if(!spawn_locs.len)
		return FALSE
	new_character.forceMove(pick(spawn_locs))
	return ..()
