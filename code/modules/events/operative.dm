/datum/round_event_control/operative
	name = "Lone Operative"
	typepath = /datum/round_event/operative
	weight = 0 //Admin only
	max_occurrences = 1

/datum/round_event/operative
	var/key_of_operative

/datum/round_event/operative/proc/get_operative(end_if_fail = 0)
	key_of_operative = null
	if(!key_of_operative)
		var/list/candidates = get_candidates(ROLE_OPERATIVE, 3000, "operative")
		if(!candidates.len)
			if(end_if_fail)
				return 0
			return find_operative()
		var/client/C = pick(candidates)
		key_of_operative = C.key
	if(!key_of_operative)
		if(end_if_fail)
			return 0
		return find_operative()
	var/datum/mind/player_mind = new /datum/mind(key_of_operative)
	player_mind.active = 1
	var/list/spawn_locs = list()
	for(var/obj/effect/landmark/L in landmarks_list)
		if(L.name in list("ninjaspawn","carpspawn"))
			spawn_locs += L.loc
	if(!spawn_locs.len)
		return kill()

	var/mob/living/carbon/human/operative = new(pick(spawn_locs))
	var/datum/preferences/A = new
	A.copy_to(operative)
	operative.dna.update_dna_identity()

	operative.equipOutfit(/datum/outfit/syndicate/full)

	var/datum/mind/Mind = new /datum/mind(key_of_operative)
	Mind.assigned_role = "Lone Operative"
	Mind.special_role = "Lone Operative"
	ticker.mode.traitors |= Mind
	Mind.active = 1

	var/obj/machinery/nuclearbomb/selfdestruct/nuke = locate() in machines
	if(nuke)
		var/nuke_code
		if(!nuke.r_code || nuke.r_code == "ADMIN")
			nuke_code = "[rand(10000, 99999)]"
			nuke.r_code = nuke_code
		else
			nuke_code = nuke.r_code

		Mind.store_memory("<B>Station Self-Destruct Device Code</B>: [nuke_code]", 0, 0)
		Mind.current << "The nuclear authorization code is: <B>[nuke_code]</B>"

		var/datum/objective/nuclear/O = new()
		O.owner = Mind
		Mind.objectives += O

	Mind.transfer_to(operative)

	message_admins("[key_of_operative] has been made into lone operative by an event.")
	log_game("[key_of_operative] was spawned as a lone operative by an event.")
	return 1

/datum/round_event/operative/start()
	get_operative()


/datum/round_event/operative/proc/find_operative()
	message_admins("Attempted to spawn a operative but there was no players available. Will try again momentarily.")
	spawn(50)
		if(get_operative(1))
			message_admins("Situation has been resolved, [key_of_operative] has been spawned as a operative.")
			log_game("[key_of_operative] was spawned as a operative by an event.")
			return 0
		message_admins("Unfortunately, no candidates were available for becoming a operative. Shutting down.")
	return kill()