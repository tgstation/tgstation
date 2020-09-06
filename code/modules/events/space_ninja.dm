/datum/round_event_control/space_ninja
	name = "Spawn Space Ninja"
	typepath = /datum/round_event/ghost_role/space_ninja
	max_occurrences = 1
	earliest_start = 20 MINUTES
	min_players = 15

/datum/round_event/ghost_role/space_ninja
	minimum_required = 1
	role_name = "Space Ninja"

/datum/round_event/ghost_role/space_ninja/spawn_role()
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/carpspawn/C in GLOB.landmarks_list)
		spawn_locs += (C.loc)
	if(!spawn_locs.len)
		message_admins("No valid spawn locations found, aborting...")
		return MAP_ERROR

	//selecting a candidate player
	var/list/candidates = get_candidates(ROLE_NINJA, null, ROLE_NINJA)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected_candidate = pick(candidates)
	var/key = selected_candidate.key

	//Prepare ninja player mind
	var/datum/mind/Mind = new /datum/mind(key)
	Mind.assigned_role = ROLE_NINJA
	Mind.special_role = ROLE_NINJA
	Mind.active = TRUE

	//spawn the ninja and assign the candidate
	var/mob/living/carbon/human/Ninja = create_space_ninja(pick(spawn_locs))
	Mind.transfer_to(Ninja)
	var/datum/antagonist/ninja/ninjadatum = new
	Mind.add_antag_datum(ninjadatum)

	if(Ninja.mind != Mind)			//something has gone wrong!
		CRASH("Ninja created with incorrect mind")

	spawned_mobs += Ninja
	message_admins("[ADMIN_LOOKUPFLW(Ninja)] has been made into a space ninja by an event.")
	log_game("[key_name(Ninja)] was spawned as a ninja by an event.")

	return SUCCESSFUL_SPAWN


//=======//NINJA CREATION PROCS//=======//

/proc/create_space_ninja(spawn_loc)
	var/mob/living/carbon/human/new_ninja = new(spawn_loc)
	var/datum/preferences/A = new()//Randomize appearance for the ninja.
	A.real_name = "[pick(GLOB.ninja_titles)] [pick(GLOB.ninja_names)]"
	A.copy_to(new_ninja)
	new_ninja.dna.update_dna_identity()
	return new_ninja
